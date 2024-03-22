import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/bloc/setting_manage/setting_manage_cubit.dart';
import 'package:kiosk/core/defined_code.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../bloc/services/services_bloc.dart';
import '../../injection_container.dart';
import '../../l10n/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingManageCubit cubit;
  late final TextEditingController imageUrlTextEditCtrl;
  late final TextEditingController uploadUrlTextEditCtrl;
  late final TextEditingController websocketUrlTextEditCtrl;
  late final TextEditingController readBarcodeLengthTextEditCtrl;
  late final TextEditingController goSettingTextEditCtrl;
  late final TextEditingController lastPrintTextEditCtrl;
  late final TextEditingController ompUidTextEditCtrl;

  @override
  void initState() {
    cubit = it<SettingManageCubit>();
    imageUrlTextEditCtrl = TextEditingController(text: cubit.state.s3ImageUrl);
    uploadUrlTextEditCtrl =
        TextEditingController(text: cubit.state.amzUploadUrl);
    websocketUrlTextEditCtrl =
        TextEditingController(text: cubit.state.websocketUrl);
    readBarcodeLengthTextEditCtrl =
        TextEditingController(text: cubit.state.readBarcodeLength.toString());
    goSettingTextEditCtrl =
        TextEditingController(text: cubit.state.goSettingBarcode);
    lastPrintTextEditCtrl =
        TextEditingController(text: cubit.state.lastPrintBarcode);
    ompUidTextEditCtrl = TextEditingController(text: cubit.state.ompUid);

    super.initState();
  }

  @override
  void dispose() async {
    imageUrlTextEditCtrl.dispose();
    uploadUrlTextEditCtrl.dispose();
    websocketUrlTextEditCtrl.dispose();
    readBarcodeLengthTextEditCtrl.dispose();
    goSettingTextEditCtrl.dispose();
    lastPrintTextEditCtrl.dispose();
    ompUidTextEditCtrl.dispose();
    windowManager.setFullScreen(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingManageCubit, SettingManageState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Setting'),
            actions: [
              IconButton(
                  onPressed: () {
                    if (state.portInfo.portName.isEmpty && kReleaseMode) {
                      return _showDialog(context);
                    }
                    context
                        .read<ServicesBloc>()
                        .add(const ServicesEvent.openBarcodePort());
                  },
                  icon: const Icon(Icons.save_rounded))
            ],
          ),
          body: SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Setting'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.device_hub),
                    title: const Text('QR Reader Port'),
                    value: BlocBuilder<SettingManageCubit, SettingManageState>(
                      builder: (deviceContext, deviceState) =>
                          Text(deviceState.portInfo.portName),
                    ),
                    onPressed: (ctx) => _selectPort(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: Text(L10n.getLanguageName(state.locale)),
                    onPressed: (context) => _selectLanguage(
                      context,
                    ),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Zone'),
                    value: _dropDownZone(context),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.add_link),
                    title: const Text('Image Url'),
                    value: Container(
                        alignment: Alignment.centerRight,
                        width: 500,
                        child: Text(state.s3ImageUrl,
                            overflow: TextOverflow.visible)),
                    onPressed: (ctx) => _imageUrlTextField(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.file_upload),
                    title: const Text('Upload Url'),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      child: Text(state.amzUploadUrl,
                          overflow: TextOverflow.visible),
                    ),
                    onPressed: (ctx) => _uploadUrlTextField(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.dataset_linked),
                    title: const Text('Server Url'),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      child: Text(state.websocketUrl,
                          overflow: TextOverflow.visible),
                    ),
                    onPressed: (ctx) => _websocketUrlTextField(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.barcode_reader),
                    title: const Text('Number of QR characters'),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      child: Text(state.readBarcodeLength.toString(),
                          overflow: TextOverflow.visible),
                    ),
                    onPressed: (ctx) => _barcodeLengthField(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.settings_applications_outlined),
                    title: const Text('Setting QR'),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      child: Text(state.goSettingBarcode.toString(),
                          overflow: TextOverflow.visible),
                    ),
                    onPressed: (ctx) => _goSettingBarcodeTextField(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.print_outlined),
                    title: const Text('Last Print QR'),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      child: Text(state.lastPrintBarcode.toString(),
                          overflow: TextOverflow.visible),
                    ),
                    onPressed: (ctx) => _lastPrintBarcodeTextField(ctx),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.qr_code),
                    title: const Text('OMP Uid'),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      child: Text(state.ompUid, overflow: TextOverflow.visible),
                    ),
                    onPressed: (ctx) => _goOmpUidTextField(ctx),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('Please set the port.'),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'))
          ],
        );
      },
    );
  }

  void _selectPort(BuildContext context) {
    final ports = SerialPort.getPortsWithFullMessages();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: ports.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(ports[index].portName),
              onTap: () {
                cubit.onChangedBarcodePort(ports[index]);
                Navigator.of(context).pop(ports[index]);
              },
            );
          },
        );
      },
    );
  }

  void _selectLanguage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: L10n.all.length,
          itemBuilder: (context, index) {
            final locale = L10n.all[index];
            return ListTile(
              title: Text(L10n.getLanguageName(locale)),
              onTap: () {
                cubit.onChangedLocal(locale);
                Navigator.of(context).pop(locale);
              },
            );
          },
        );
      },
    );
  }

  Widget _dropDownZone(BuildContext context) {
    return BlocBuilder<SettingManageCubit, SettingManageState>(
      builder: (context, state) => DropdownButton(
          isDense: true,
          items: KindZoneType.values
              .where((e) => e != KindZoneType.pure && e != KindZoneType.low)
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e != KindZoneType.quick ? 'lowhigh' : e.name),
                ),
              )
              .toList(),
          value: state.zone,
          onChanged: (value) => cubit.onChnagedZone(value!)),
    );
  }

  void _imageUrlTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Url Setting'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: imageUrlTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onSaveImageUrl(imageUrlTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _uploadUrlTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Url Setting'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: uploadUrlTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onSaveUploadUrl(uploadUrlTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _websocketUrlTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Server Url Setting'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: websocketUrlTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onSaveWebsocketUrl(websocketUrlTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _barcodeLengthField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Text Length'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: readBarcodeLengthTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onSaveBarcodeLength(readBarcodeLengthTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _goOmpUidTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('OMP Uid Setting'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: ompUidTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onSaveOmpUid(ompUidTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _goSettingBarcodeTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin QR Setting'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: goSettingTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onSettingBarcode(goSettingTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _lastPrintBarcodeTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Last Print QR'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: lastPrintTextEditCtrl,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<SettingManageCubit>()
                    .onLastPrintBarcode(lastPrintTextEditCtrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
