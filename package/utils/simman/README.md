
# Модуль управления СИМ картами 3g модема

## Описание
Модуль предназначен для управления переключением СИМ карт 3G модема. 

## Сборка модуля
* подготовить OpenWRT SDK 
* скопировать содержимое по тути <SDK_PATH>/package/ 
* добавить в сборку пакет "simman"

> make menuconfig

> Utilities-simman [*|M]

* собрать пакет

> make package/simman/{clean,compile} V=s
 
После сборки пакет должен быть по пути <SDK_PATH>/bin/<target_platform>/packages/base/

## Сборка плагина для luci

* скопировать содержимое по тути <SDK_PATH>/feeds/luci/application/ 
* создать симлинк пакета по пути <SDK_PATH>/package/feeds/luci/
  
> cd {SDK-PATH}/package/feeds/luci/

> ln -s {SDK-PATH}/feeds/luci/application/{module-name} ./{module-name}	

* добавить в сборку пакет "luci-app-simman"
  
> make menuconfig

> LuCI--Applications--luci-app-simman [*|M]

* собрать пакет
  
> make package/feeds/luci/luci-app-simman/{clean,compile} V=s
 
После сборки пакет должен быть по пути <SDK_PATH>/bin/<target_platform>/packages/luci/

**Для установки на готовую систему:**
* скопировать собраный пакет на устройство, к примеру в директорию /tmp/
* установить пакет

> opkg install /tmp/{имя пакета}

## Настройка модуля

Настроечный файл лежит по пути /etc/config/simman.
Установку параметров можно произвести из консоли, путем редактирования параметров в файле настроек или через веб во вкладке Services/Simman.

### Описание параметров 

Web name                       | UCI name | Info
-------------------------------|----------|------
Enabled |	enadled |  _разрешение работы модуля_ 
Number of failed attempts | retry_num | _число неудачных попыток пинга тестовых серверов. Если ни от одного из серверов (парам. "IP address of remote servers") нет ответа, то производится попытка переключения на другую СИМ карту._ 
Period of check | check_period | _период проверки доступности тестовых серверов, в секундах_
Return to priority SIM | delay | _период переключения на приоритетную СИМ карту, в секундах_ 
AT modem device name | atdevice | _устройство АТ-модема для получения текущих параметров (IMEI, CCID, уровень сигнала и пр.)_
IP address of remote servers | testip | _список тестровых серверов (максимум до 5 серверов)._ 

### Настройки СИМ карт

* Priority - _приоритет включения (0 - низкий, 1 - высокий)._
* APN - _имя точки доступа оператора_
* Pincode - _пин код СИМ карты_
* User name - _GPRS имя пользователя_
* Password - _GPRS пароль пользователя_


   	 

 
 	 








