#!/system/bin/sh
#字体问题后续再说.jpg
echo "███████ ████████  ██████  ██████   █████   ██████  ███████" 
echo "██         ██    ██    ██ ██   ██ ██   ██ ██       ██     "
echo "███████    ██    ██    ██ ██████  ███████ ██   ███ █████  " 
echo "     ██    ██    ██    ██ ██   ██ ██   ██ ██    ██ ██     " 
echo "███████    ██     ██████  ██   ██ ██   ██  ██████  ███████" 
echo ""
echo "██╗  ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗███████╗██████╗ "
echo "██║  ██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝██╔════╝██╔══██╗"
echo "███████║██║     ███████║█████╗  ██║     █████╔╝ █████╗  ██████╔╝"
echo "██╔══██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ██╔══╝  ██╔══██╗"
echo "██║  ██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗███████╗██║  ██║"
echo "╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"                                                                                                                          
                                                                                                                                                                    
if [ "$(id -u)" -ne 0 ]; then
  echo "未检测到 root 权限，是否继续？(y/n)"
  read -r ch
  if [ "$ch" != "y" ]; then
    exit 1
  fi
fi

os=$(uname -o)
if [ "$os" != "Android" ] && [ "$os" != "Toybox" ]; then
  echo "当前系统为 $os，已知部分安卓设备也会显示为linux，是否继续？(y/n)"
  read -r ch
  if [ "$ch" != "y" ]; then
    exit 1
  fi
fi

StorageType=""
if [ -f /sys/block/mmcblk0/device/life_time ]; then
  StorageType="eMMC"
else
#用了很硬的编码方式，可能不支持小米等OEM
  getUFS=$(find /dev/block/platform/soc -type d -name "1d84000.ufshc" 2>/dev/null)
  if [ "$getUFS" != "" ]; then
    StorageType="UFS"
  fi
fi

#采用了读取CID的方法获取emmc信息，未经严格测试，信息不一定准确
GeteMMCinfo() {
  cidpath=$(find /sys/class/mmc_host/mmc0/mmc0:0001 -name "cid" | head -n 1)
  if [ -z "$cidpath" ]; then
    echo "未找到 eMMC CID，尝试获取基本信息"
    manfid=$(cat /sys/block/mmcblk0/device/manfid 2>/dev/null)
    chipinfo=$(cat /sys/block/mmcblk0/device/chipinfo 2>/dev/null)
    name=$(cat /sys/block/mmcblk0/device/name 2>/dev/null)
    oemid=$(cat /sys/block/mmcblk0/device/oemid 2>/dev/null)
    prv=$(cat /sys/block/mmcblk0/device/prv 2>/dev/null)
    date=$(cat /sys/block/mmcblk0/device/date 2>/dev/null)
    echo "型号$chipinfo-$name"
    echo "制造商ID: $manfid"
    echo "OEMID: $oemid"
    echo "版本: $prv"
    echo "生产日期: $date"
  fi
    date=$(cat /sys/block/mmcblk0/device/date 2>/dev/null)
    chipinfo=$(cat /sys/block/mmcblk0/device/chipinfo 2>/dev/null)
    cid=$(cat "$cidpath")
    echo "CID: $cid"
    mid=${cid:0:2}
    oid=${cid:2:4}
    pnm_hex=${cid:6:12}
    prv=${cid:18:2}
    psn=${cid:20:8}
    mdt=${cid:28:4}
    pnm_ascii=$(echo "$pnm_hex" | xxd -r -p)
    prv_major=$((0x${prv:0:1}))
    prv_minor=$((0x${prv:1:1}))
#根据CID解析出来的不太对，先暂时用直接读取的办法    
#    mdt_byte=$((0x$mdt))
#    year=$(( ((mdt_byte >> 4) & 0xFF) + 2000 ))
#    month=$(( mdt_byte & 0x0F ))
    
    echo "制造商 ID (MID): 0x$mid"
    echo "OEM ID (OID): 0x$oid"
    echo "产品名称 (PNM): $pnm_ascii $chipinfo"
    echo "产品版本 (PRV): $prv_major.$prv_minor"
    echo "产品序列号 (PSN): 0x$psn"
    echo "生产日期 (MDT): $date"

}

GetUFSinfo() {
#用了很硬的编码方式，依旧可能不支持小米等OEM
  UFSvendor="/sys/block/sda/device/vendor"
  UFSmodel="/sys/block/sda/device/model"
  UFSrev="/sys/block/sda/device/rev"
  if [ -n "$getUFS" ]; then
    vendor=$(cat "$UFSvendor" 2>/dev/null)
    model=$(cat "$UFSmodel" 2>/dev/null)
    rev=$(cat "$UFSrev" 2>/dev/null)
    echo "厂商: $vendor"
    echo "型号: $model"
    echo "修订: $rev"
  else
    echo ""
  fi
}

CheckeMMClife() {
  if [ -f /sys/block/mmcblk0/device/life_time ]; then
    bDeviceLifeTimeEstA=$(cut -f1 -d ' ' /sys/block/mmcblk0/device/life_time)
    case $bDeviceLifeTimeEstA in
      "0x00"|"0x0") echo '寿命无法读取或闪存很健康' ;;
      "0x01"|"0x1") echo '已使用寿命 0% ~ 10%' ;;
      "0x02"|"0x2") echo '已使用寿命 10% ~ 20%' ;;
      "0x03"|"0x3") echo '已使用寿命 20% ~ 30%' ;;
      "0x04"|"0x4") echo '已使用寿命 30% ~ 40%' ;;
      "0x05"|"0x5") echo '已使用寿命 40% ~ 50%' ;;
      "0x06"|"0x6") echo '已使用寿命 50% ~ 60%' ;;
      "0x07"|"0x7") echo '已使用寿命 60% ~ 70%' ;;
      "0x08"|"0x8") echo '已使用寿命 70% ~ 80%' ;;
      "0x09"|"0x9") echo '已使用寿命 80% ~ 90%' ;;
      "0x0A"|"0xA") echo '已使用寿命 90% ~ 100%' ;;
      "0x0B"|"0xB") echo '已超过预估寿命' ;;
      *) echo '已使用寿命 未知' ;;
    esac
  else
    echo "啥也没读取到，看看你给的权限够不够？"
  fi
}

CheckUFSlife() {
  bDeviceLifeTimeEstA=""
  if [ -f /sys/devices/platform/soc/1d84000.ufshc/health_descriptor/life_time_estimation_a ]; then
    bDeviceLifeTimeEstA=$(cat /sys/devices/platform/soc/1d84000.ufshc/health_descriptor/life_time_estimation_a)
  elif [ -f /sys/devices/virtual/mi_memory/mi_memory_device/ufshcd0/dump_health_desc ]; then
    bDeviceLifeTimeEstA=$(grep bDeviceLifeTimeEstA /sys/devices/virtual/mi_memory/mi_memory_device/ufshcd0/dump_health_desc | cut -f2 -d '=' | cut -f2 -d ' ')
  else
    dump_files=$(find /sys -name "dump_*_desc" | grep ufshc)
    for line in $dump_files; do
      str=$(grep 'bDeviceLifeTimeEstA' "$line" | cut -f2 -d '=' | cut -f2 -d ' ')
      if [ -n "$str" ]; then
        bDeviceLifeTimeEstA="$str"
        break
      fi
    done
  fi

  case $bDeviceLifeTimeEstA in
    "0x00"|"0x0") echo '寿命无法读取或闪存很健康' ;;
    "0x01"|"0x1") echo '已使用寿命 0% ~ 10%' ;;
    "0x02"|"0x2") echo '已使用寿命 10% ~ 20%' ;;
    "0x03"|"0x3") echo '已使用寿命 20% ~ 30%' ;;
    "0x04"|"0x4") echo '已使用寿命 30% ~ 40%' ;;
    "0x05"|"0x5") echo '已使用寿命 40% ~ 50%' ;;
    "0x06"|"0x6") echo '已使用寿命 50% ~ 60%' ;;
    "0x07"|"0x7") echo '已使用寿命 60% ~ 70%' ;;
    "0x08"|"0x8") echo '已使用寿命 70% ~ 80%' ;;
    "0x09"|"0x9") echo '已使用寿命 80% ~ 90%' ;;
    "0x0A"|"0xA") echo '已使用寿命 90% ~ 100%' ;;
    "0x0B"|"0xB") echo '已超过预估寿命' ;;
    *) echo '已使用寿命 未知' ;;
  esac
}

case $StorageType in
  "eMMC")
    echo "检测到eMMC"
    GeteMMCinfo
    echo "---"
    CheckeMMClife
    ;;
  "UFS")
    echo "检测到UFS"
    GetUFSinfo
    echo "---"
    CheckUFSlife
    ;;
  *)
    echo "未检测到支持的存储类型"
    ;;
esac
