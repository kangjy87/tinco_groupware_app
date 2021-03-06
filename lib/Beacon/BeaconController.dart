import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hr_project_flutter/Beacon/BeaconManager.dart';

class BeaconController extends GetxController {
  var bluetoothState = BluetoothState.stateOff.obs;
  var authorizationStatus = AuthorizationStatus.notDetermined.obs;
  var isAuthorization = false.obs;
  var isLocationService = false.obs;
  var scanCount = 0.obs;

  @override
  void onInit() {
    BeaconManager()
      ..buildBluetooth(
        () {
          bluetoothState.value = BeaconManager().bluetoothState;
        },
        () {
          bluetoothState.value = BeaconManager().bluetoothState;
          authorizationStatus.value = BeaconManager().authorizationStatus;
          isAuthorization.value = BeaconManager().isAuthorization;
          isLocationService.value = BeaconManager().isLocationService;
        },
      )
      ..buildBeacon(
        () {
          if (BeaconManager().isBeaconEmpty == true) {
            scanCount.value = 0;
          } else {
            scanCount.value++;
          }
        },
      )
      ..buildBeaconRegion('BeaconType1', '8fef2e11-d140-2ed1-2eb1-4138edcabe09') // Beacon Device 등록
      ..buildBeaconRegion('BeaconType2', '4d9c357a-0640-11ec-9a03-0242ac130003')
      ..buildBeaconRegion('TDI_Mars', 'fda50693-a4e2-4fb1-afcf-c6eb07647821')
      ..initialize();

    super.onInit();
  }

  @override
  void onClose() {
    BeaconManager().close();
    super.onClose();
  }
}

class BeaconBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BeaconController>(() => BeaconController());
  }
}
