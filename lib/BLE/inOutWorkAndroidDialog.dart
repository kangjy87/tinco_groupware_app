import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hr_project_flutter/Page/GroupwareControler.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:lottie/lottie.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;
var isScanns = false ;
inAndOutWorkshowDialog_android(BuildContext buidContext){
  GroupwareControler groupwareControler =Get.find<GroupwareControler>();
  groupwareControler.strServerRequest.value = groupwareControler.strCommute.value == "in" ? "출근 체크중 입니다...":"퇴근 체크중 입니다..." ;
  groupwareControler.beaconList.value.clear();
  return showDialog(
      context: buidContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: 300,
            height: 300,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children :[
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0,0, 0, 0),
                        child: Lottie.asset('assets/splash.json'),
                        height: 300,
                        width: 300,),
                      Obx(()=>Container(
                        padding: EdgeInsets.fromLTRB(50,180, 50, 90),
                        width: double.infinity,
                        child: Text(groupwareControler.strServerRequest.value
                            ,textAlign: TextAlign.center
                            ,style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff454f63))),
                      )),
                    ],
                  )
                ]
            ),
          ),
        );
      });
}
inAndOutWorkScanns_android(Function onServerSend){
  bool scanningCheck  = false ;
  GroupwareControler groupwareControler =Get.find<GroupwareControler>();
  groupwareControler.strServerRequest.value = groupwareControler.strCommute.value == "in" ? "출근 체크중 입니다...":"퇴근 체크중 입니다..." ;
  List<BeaconData> beaconList = [] ;
  // BLE 스캔 상태 얻기 위한 리스너
  var isScanningEndCheck = false ;
  flutterBlue.isScanning.listen((isScanning) {
    print('지금 상태는?????????${isScanning}');
    isScanns = isScanning ;
    if(isScanns){
      isScanningEndCheck = true ;
    }
    //스캔시작 하고나서 4초 스캔이 끝나면 서버통신을 한다.
    if(isScanning == false && isScanningEndCheck == true && scanningCheck == false){
      scanningCheck = true ;
      isScanningEndCheck == false ;
      onServerSend();
    }
  });
  //////////////////////////////////////////////////////////스캔시작
  if(!isScanns){
    // 스캔 중이 아니라면
    // 기존에 스캔된 리스트 삭제
    // scanResultList.clear();
    // 스캔 시작, 제한 시간 4초
    groupwareControler.beaconList.value.clear();
    beaconList.clear();
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    // 스캔 결과 리스너
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results.where((element) => deviceName(element) != "N/A")) {
        BeaconData data = BeaconData();
        data.bssid = r.device.id.id ;
        data.uuid = "";
        data.major = "0" ;
        data.minor = "0" ;
        data.rssi = r.rssi ;
        // print('${deviceName(r)}구른다!!!!!!${r.device.id.id}!!!!!!!!!!${r.rssi}');
        if(beaconList.where((element) => element.bssid == r.device.id.id).length == 0){
          beaconList.add(data);
        }else if(beaconList.where((element) => element.bssid == r.device.id.id).length == 1
        && groupwareControler.beaconList.value.where((element) => element.bssid == r.device.id.id).length == 0){
          groupwareControler.beaconList.value.add(data);
        }
      }
      // print('${results.length}>>>>>>>>>>>>>>>>>>>${scanResultList.value.length}');
      // UI 갱신
    });
  }else{
    stop();
    //다시 작동하게 해주자.
  }
}


String deviceName(ScanResult r) {
  String name = '';

  if (r.device.name.isNotEmpty) {
    // device.name에 값이 있다면
    name = r.device.name;
  } else if (r.advertisementData.localName.isNotEmpty) {
    // advertisementData.localName에 값이 있다면
    name = r.advertisementData.localName;
  } else {
    // 둘다 없다면 이름 알 수 없음...
    name = 'N/A';
  }
  return name ;
}

stop(){
  if(isScanns){
    // 스캔 중이라면 스캔 정지
    flutterBlue.stopScan();
  }
}