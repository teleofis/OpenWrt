#include <stdio.h>
#include <stdbool.h>
#include <sys/socket.h>
#include <sys/timerfd.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
#include <strings.h>
#include <string.h>
#include <arpa/inet.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/epoll.h>
#include <signal.h>
#include <pthread.h>
#include <termios.h>

#include "uci.h"
#include "log.h"

#define MODE_DISABLED       0
#define MODE_SERVER         1
#define MODE_CLIENT         2

#define PARITY_NONE         0
#define PARITY_EVEN         1
#define PARITY_ODD          2

#define EPOLL_RUN_TIMEOUT       -1
#define MAX_CLIENTS_IN_QUEUE    10

#define MAX_EPOLL_EVENTS        MAX_CLIENTS_IN_QUEUE + 3  // + timer + listen socket + com-port
#define NUM_OF_DEVICES          10  // num of services (e.g. RS232, RS485 means 2)

#define MAX_TCP_BUF_SIZE        1024
#define MAX_SERIAL_BUF_SIZE     4096


typedef struct 
{
    int mode;
    bool modeChanged;
    char *deviceName;
    int baudRate;
    int byteSize;
    int parity;
    int stopBits;
    int serverPort;
    int clientHost;
    int clientPort;
    bool clientAuth;
    int clientCheckTimeoutUS;
} device_config_t;

void *ServerThreadFunc(void *args);
char *GetUCIParam(char *uci_path);

/*****************************************/
/*************** MAIN FUNC ***************/
/*****************************************/
int main(int argc, char **argv)
{
    pthread_t thread[NUM_OF_DEVICES] = {0};
    pthread_attr_t threadAttr; 
    pthread_attr_init(&threadAttr); 
    pthread_attr_setdetachstate(&threadAttr, PTHREAD_CREATE_DETACHED); 

    device_config_t deviceConfig[NUM_OF_DEVICES];

    /// test
    deviceConfig[0].mode = MODE_DISABLED;
    deviceConfig[0].serverPort = 30000;
    deviceConfig[0].deviceName = "/dev/ttyAPP1";
    deviceConfig[0].baudRate = 9600;

    deviceConfig[1].mode = MODE_DISABLED;
    deviceConfig[1].serverPort = 30001;
    deviceConfig[1].deviceName = "dev/one";
    //

    int i;
    int result;

    
    /* Check devices' settings */
    for(i = 0; i < NUM_OF_DEVICES; i++)
    { 
        //GetFullDeviceConfig(i); // ВЫЧИТЫВАЕМ ВСЕ КОНФИГИ ИЗ UCI В deviceConfig[i]

        // ACCODING TO MODE START CLIENT OR SERVER THREAD
        if(deviceConfig[i].mode == MODE_SERVER)
        {
            result = pthread_create(&thread[i], &threadAttr, ServerThreadFunc, (void*) &deviceConfig[i]);
            if(result != 0) 
                LOG("Creating server thread for dev %s false. Error: %d\n", deviceConfig[i].deviceName, result);
            else
                LOG("Server thread is started for dev %s\n", deviceConfig[i].deviceName);
        }
        else if (deviceConfig[i].mode == MODE_CLIENT)
        {
            // ТУТ БУДЕТ СТАРТОВАТЬ КЛИЕНТСКИЙ ПОТОК
        }
    }

    while (1) 
    {
        /*for(i = 0; i < NUM_OF_DEVICES; i++)
        { 
            GetModeChangedConfig(i);           // ВЫЧИТЫВАЕМ ФЛАГ ИЗМЕНЕНИЯ РЕЖИМА РАБОТЫ ИЗ UCI В deviceConfig[i].modeChanged

            if(serviceConfig[i].modeChanged)    // ЕСЛИ РЕЖИМ РАБОТЫ ИЗМЕНИЛСЯ
            {
                // IF ANY THREAD IS WORKING ON THIS DERVICE, STOP IT
                if(thread[i] != 0)
                {  
                    result = pthread_cancel(thread[i]);
                    thread[i] = 0;
                    if(result != 0) 
                    {
                        LOG("Stopping server thread for dev %d false. Error: %d\n", i, result);
                    } else
                    {
                        LOG("Server thread is stopped for dev %d\n", i);
                    }
                }
                
                // READ FULL CONFIGURATION FOR OUR DEVICE FROM UCI TO deviceConfig[i]
                GetFullDeviceConfig(i); 

                // ACCODING TO MODE START CLIENT OR SERVER THREAD
                if(deviceConfig[i].mode == MODE_SERVER)
                {
                    result = pthread_create(&thread[i], &threadAttr, ServerThreadFunc, (void*) &deviceConfig[i]);

                    if(result != 0) 
                        LOG("Creating server thread for dev %s false. Error: %d\n", deviceConfig[i].deviceName, result);
                    else
                        LOG("Server thread is started for dev %s\n", deviceConfig[i].deviceName);
                }
                else if (deviceConfig[i].mode == MODE_CLIENT)
                {
                    // ТУТ БУДЕТ СТАРТОВАТЬ КЛИЕНТСКИЙ ПОТОК
                }

                // SET BACK OUR FLAG AND WRITE IT TO UCI CONFIG FILE
                serviceConfig[i].modeChanged = false;
                SetModeChangedConfig(i);
            }


        }
        LOG("\n");*/



        //LOG("...\n");
        usleep(1000000);
    }
    return 0;
}

/*****************************************/
/************* SERVER FUNC ***************/
/*****************************************/
void *ServerThreadFunc(void *args)
{ 
    device_config_t deviceConfig = *(device_config_t*) args;

    int dataBufferSize = MAX_SERIAL_BUF_SIZE;
    int listeningServerPort = deviceConfig.serverPort;

    int lastActiveConnSocket = -1, listenSocket, eventSource;
    struct sockaddr_in networkAddr;
    char dataBuffer[dataBufferSize];
    int numOfReadBytes;

    int blockOther = 0;
    int blockSource = -1;

    struct epoll_event epollConfig;
    struct epoll_event epollEventArray[MAX_EPOLL_EVENTS];

    int numOfNewEvents;
    int i, result;
    uint32_t currentEvents = 0;

    int epollFD = epoll_create(MAX_EPOLL_EVENTS);


    /////////////////////////
    /**** Listen socket ****/
    /////////////////////////

    listenSocket = socket(AF_INET, SOCK_STREAM, 0);     // 0 - default protocol (TCP in this case)
    if(listenSocket < 0)
    {
        LOG("Error while creating a listening socket\n");
    }

    networkAddr.sin_family = AF_INET;
    networkAddr.sin_port = htons(listeningServerPort);    
    networkAddr.sin_addr.s_addr = htonl(INADDR_ANY);    // receive data from any client address
    fcntl(listenSocket, F_SETFL, O_NONBLOCK);           // set listening socket as nonblocking

    // sometimes in case of programm restart socket can hang, so we have to do this:
    int yes=1;
    if (setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes)) == -1)
    {
        perror("setsockopt");
        exit(1);
    }

    // bind listening socket with network interface(port,...)
    result = bind(listenSocket, (struct sockaddr *)&networkAddr, sizeof(networkAddr));
    if(result < 0)
    {
        LOG("Error while listening socket binding: %d\n", result);
    }

    epollConfig.events = EPOLLIN | EPOLLPRI | EPOLLERR | EPOLLHUP;
    epollConfig.data.fd = listenSocket;
    // add our listening socket into epoll
    result = epoll_ctl(epollFD, EPOLL_CTL_ADD, listenSocket, &epollConfig);
    if(result < 0)
    {
        LOG("Error while listening socket epoll regisration\n");
    }


    /////////////////////////
    /***** Serial Port *****/
    /////////////////////////

    struct termios serialPortConfig;

    /// here we must forbid access to serial from other apps

    ///// open serial
    int serialPort = open(deviceConfig.deviceName, O_RDWR | O_NOCTTY);
    if (serialPort < 0)
    {
        LOG("Error %d while opening dev %s", serialPort, deviceConfig.deviceName);
        pthread_exit(NULL);
    }

    // read config
    if (tcgetattr(serialPort, &serialPortConfig) != 0)
    {
        LOG("Error while reading port config %s", deviceConfig.deviceName);
        pthread_exit(NULL);
    }
    bzero(&serialPortConfig, sizeof(serialPortConfig)); // clear struct for new port settings

    // set config 
    cfsetospeed(&serialPortConfig, deviceConfig.baudRate);
    cfsetispeed(&serialPortConfig, deviceConfig.baudRate);

    serialPortConfig.c_cflag = CLOCAL | CREAD | CS8 ;   // Enable the receiver and set local mode, 8n1 ???
    serialPortConfig.c_cc[VMIN]     = 0;                // blocking read until 1 character arrives (0 - no, 1 - yes)
    serialPortConfig.c_cc[VTIME]    = 0;                // inter-character timer

    // write config
    tcflush(serialPort, TCIFLUSH);                      // clean the line
    tcsetattr(serialPort, TCSANOW, &serialPortConfig);  // change config right now (may be TCSADRAIN,TCSAFLUSH)

    // add serial port fd to epoll
    epollConfig.data.fd = serialPort;
    epollConfig.events = EPOLLIN | EPOLLET; // message, edge trigger
    result = epoll_ctl(epollFD, EPOLL_CTL_ADD, serialPort, &epollConfig);
    if(result < 0)
    {
        LOG("Error while serial port epoll regisration\n");
    }


    /////////////////////////
    /**** Timer for TCP ****/
    /////////////////////////

    int tcpHoldConnTime = 20;
    struct itimerspec newValue;
    struct itimerspec oldValue;
    bzero(&newValue,sizeof(newValue));  
    bzero(&oldValue,sizeof(oldValue));

    struct timespec ts;
    ts.tv_sec = tcpHoldConnTime;
    ts.tv_nsec = 0;
    newValue.it_value = ts;

    int TCPtimer = timerfd_create(CLOCK_MONOTONIC,TFD_NONBLOCK);
    if(TCPtimer < 0)
    {
        LOG("Error while timerfd create");
    }

    // add timer fd to epoll
    epollConfig.events = EPOLLIN | EPOLLET;
    epollConfig.data.fd = TCPtimer;
    result = epoll_ctl(epollFD, EPOLL_CTL_ADD, TCPtimer, &epollConfig);
    if(result < 0)
    {
        LOG("Epoll timer addition error\n");
    }


    // begin waiting for clients
    listen(listenSocket, MAX_CLIENTS_IN_QUEUE);
    LOG("Listening on dev %s port %d\n", deviceConfig.deviceName, listeningServerPort);


    while(1)
    {
        numOfNewEvents = epoll_wait(epollFD, epollEventArray, MAX_EPOLL_EVENTS, EPOLL_RUN_TIMEOUT);

        for(i = 0; i < numOfNewEvents; i++) 
        {
            eventSource = epollEventArray[i].data.fd;
            currentEvents = epollEventArray[i].events;

            // if we have a new connection
            if(eventSource == listenSocket)   
            {
                result = accept(listenSocket, NULL, NULL); // we don't care about a client address
                if(result < 0)
                {
                    LOG("Error while accepting connection\n");
                }
                else
                    lastActiveConnSocket = result;

                fcntl(lastActiveConnSocket, F_SETFL, O_NONBLOCK);           // set listening socket as nonblocking
                LOG("New incoming connection\n");

                epollConfig.data.fd = lastActiveConnSocket;
                epollConfig.events = EPOLLIN | EPOLLET; // message, edge trigger
                result = epoll_ctl(epollFD, EPOLL_CTL_ADD, lastActiveConnSocket, &epollConfig);
                if(result < 0)
                {
                    LOG("Epoll connection addition error %d\n", result);
                }
            }

            // data from serial
            else if(eventSource == serialPort)
            {
                numOfReadBytes = read(serialPort, dataBuffer, dataBufferSize);
                send(lastActiveConnSocket, dataBuffer, numOfReadBytes, 0);
            }

            else if(eventSource == TCPtimer) 
            {
                blockOther = 0; // free access for all clients
            }

            // data from TCP on existing connection
            else if(currentEvents & EPOLLIN) 
            {
                numOfReadBytes = recv(eventSource, dataBuffer, dataBufferSize, 0);
                if(numOfReadBytes > 0)
                {
                    // if block source sent data or block is disabled, we handle it
                    if(blockOther == 0 || blockSource == eventSource)
                    {
                        // close access for other untill (last activity timer will signalize) or (our TCP will close)
                        blockOther = 1;
                        blockSource = eventSource;
                        result = timerfd_settime(TCPtimer, 0, &newValue, &oldValue);
                        if(result < 0)
                        {
                            LOG("Error while timer setup");
                        }
                        dataBuffer[numOfReadBytes] = 0;
                        write(serialPort, dataBuffer, numOfReadBytes);
                        lastActiveConnSocket = eventSource;
                    }
                    else
                        LOG("Data refused\n");  
                }
                else // if someone want to close connection
                {
                    close(eventSource);
                    epollConfig.data.fd = eventSource;
                    epoll_ctl(epollFD, EPOLL_CTL_DEL, eventSource, &epollConfig);
                    // if block source wanted to close connection, we free access for all
                    if(blockSource == eventSource) 
                    {
                        blockOther = 0; // free access for all clients
                    }
                    LOG("Connection closed\n");
                }
            }

            else
            {
                LOG("Unknown epoll event\n");
            }
        }      
    }
} 

char *GetUCIParam(char *uci_path)
{
   char path[128]= {0};
   char buffer[80] = { 0 };
   struct uci_ptr ptr;
   struct uci_context *context = uci_alloc_context();

   if(!context) return NULL;

   strcpy(path, uci_path);

   if ((uci_lookup_ptr(context, &ptr, path, true) != UCI_OK) ||
         (ptr.o==NULL || ptr.o->v.string==NULL)) 
   { 
     uci_free_context(context);
     return NULL;
   }

   if(ptr.flags & UCI_LOOKUP_COMPLETE)
      strcpy(buffer, ptr.o->v.string);

   uci_free_context(context);

   return strdup(buffer);
}
