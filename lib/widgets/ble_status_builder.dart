import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class BleStatusBuilder extends StatelessWidget {
  final Stream<PeripheralConnectionState> bleState;

  const BleStatusBuilder({Key key, this.bleState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _theme = CustomTheme.getThemeFromStorage();
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _theme.secondBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _theme.notifications,
            blurRadius: 5,
            spreadRadius: -2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<PeripheralConnectionState>(
            stream: bleState,
            initialData: PeripheralConnectionState.disconnected,
            builder: (context, snapshot) {
              var type = snapshot.data;
              if (type == PeripheralConnectionState.connected)
                return Icon(Icons.check_circle, color: Colors.greenAccent);
              if (type == PeripheralConnectionState.connecting ||
                  type == PeripheralConnectionState.disconnecting) {
                return SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(_theme.accentColor),
                  ),
                );
              }
              return Icon(Icons.cancel, color: Colors.redAccent);
            },
          ),
          Icon(
            Icons.bluetooth,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
