import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_animated_button/simple_animated_button.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
//import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
//import 'package:convert/convert.dart';
//import 'dart:convert';

import 'extensions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const JoystickExampleApp());
}

class JoystickExampleApp extends StatefulWidget {
  const JoystickExampleApp({Key? key}) : super(key: key);

  @override
  State<JoystickExampleApp> createState() => _JoystickExampleAppState();
}

class _JoystickExampleAppState extends State<JoystickExampleApp> {
  BluetoothConnection? _connection;
  BluetoothDevice? _deviceConnected;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MainPage(
          connection: _connection,
          deviceConnected: _deviceConnected,
          onConnectionChanged: (connection, device) {
            setState(() {
              _connection = connection;
              _deviceConnected = device;
            });
          },
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final BluetoothConnection? connection;
  final BluetoothDevice? deviceConnected;
  final Function(BluetoothConnection?, BluetoothDevice?) onConnectionChanged;

  const MainPage(
      {Key? key,
      required this.connection,
      required this.deviceConnected,
      required this.onConnectionChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100], // Fondo gris claro para toda la página
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedLayerButton(
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JoystickExample(
                            connection: connection,
                            deviceConnected: deviceConnected,
                          )),
                );
              },
              buttonHeight: 55,
              buttonWidth: 200,
              animationDuration: const Duration(milliseconds: 200),
              animationCurve: Curves.ease,
              topDecoration: BoxDecoration(
                color: Colors.lightBlue[600], // Color azul claro
                border:
                    Border.all(color: Colors.blue, width: 2.0), // Borde azul
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
              ),
              topLayerChild: Text(
                "Control",
                style: TextStyle(
                  fontSize: 20, // Tamaño de la fuente
                  fontFamily: 'Roboto', // Nombre de la fuente
                  fontWeight: FontWeight.bold, // Grosor de la fuente
                  color: Colors.white, // Color de la fuente
                ),
              ),
              baseDecoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(color: Colors.green, width: 2.0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 5), // Espacio entre los botones
            ElevatedLayerButton(
              onClick: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DispositivosBlue(
                      connection: connection,
                      deviceConnected: deviceConnected,
                    ),
                  ),
                );

                if (result != null) {
                  onConnectionChanged(result['connection'], result['device']);
                }
              },
              buttonHeight: 60,
              buttonWidth: 270,
              animationDuration: const Duration(milliseconds: 200),
              animationCurve: Curves.ease,
              topDecoration: BoxDecoration(
                color: Colors.orange[500], // Color naranja claro
                border: Border.all(
                    color: Colors.orange, width: 2.0), // Borde naranja
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
              ),
              topLayerChild: Text(
                "Dispositivos Bluetooth",
                style: TextStyle(
                  fontSize: 20, // Tamaño de la fuente
                  fontFamily: 'Roboto', // Nombre de la fuente
                  fontWeight: FontWeight.bold, // Grosor de la fuente
                  color: Colors.white, // Color de la fuente
                ),
              ),
              baseDecoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(color: Colors.green, width: 2.0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DispositivosBlue extends StatefulWidget {
  final BluetoothConnection? connection;
  final BluetoothDevice? deviceConnected;

  const DispositivosBlue({Key? key, this.connection, this.deviceConnected})
      : super(key: key);

  @override
  State<DispositivosBlue> createState() => _DispositivosBlueState();
}

class _DispositivosBlueState extends State<DispositivosBlue> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  //StreamSubscription<List<int>>? _streamSubscription;

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  void initState() {
    super.initState();

    _requestPermission();

    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_OFF:
          setState(() => _bluetoothState = false);
          break;
        case BluetoothState.STATE_ON:
          setState(() => _bluetoothState = true);
          break;
        default:
          break;
      }
    });

    _connection = widget.connection;
    _deviceConnected = widget.deviceConnected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Dispositivos Bluetooth',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20, // Tamaño del texto del título
            fontWeight: FontWeight.bold, // Peso de la fuente
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _controlBT(),
            _infoDevice(),
            const SizedBox(height: 4), // Espacio entre los widgets
            Expanded(child: _listDevices()),
          ],
        ),
      ),
    );
  }

  Widget _controlBT() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        value: _bluetoothState,
        onChanged: (bool value) async {
          if (value) {
            await _bluetooth.requestEnable();
          } else {
            await _bluetooth.requestDisable();
          }
        },
        title: Text(
          _bluetoothState ? "Bluetooth encendido" : "Bluetooth apagado",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoDevice() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          "Conectado a: ${_deviceConnected?.name ?? "  ######"}",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: _connection?.isConnected ?? false
            ? TextButton(
                onPressed: () async {
                  await _connection?.finish();
                  setState(() => _deviceConnected = null);
                },
                child: const Text("Desconectar"),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Colors.red, // Uso de foregroundColor en lugar de primary
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : TextButton(
                onPressed: _getDevices,
                child: const Text("Ver dispositivos"),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Colors.blue, // Uso de foregroundColor en lugar de primary
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _listDevices() {
    return _isConnecting
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ...[
                    for (final device in _devices)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(
                                  0, 2), // Cambia la posición de la sombra
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            device.name ?? device.address,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: TextButton(
                            child: const Text('Conectar'),
                            onPressed: () async {
                              setState(() => _isConnecting = true);

                              _connection = await BluetoothConnection.toAddress(
                                  device.address);
                              _deviceConnected = device;
                              _devices = [];
                              _isConnecting = false;

                              //_receiveData();

                              setState(() {});

                              Navigator.pop(context, {
                                'connection': _connection,
                                'device': _deviceConnected,
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors
                                  .green, // Uso de foregroundColor en lugar de primary
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
  }
}

class JoystickExample extends StatefulWidget {
  final BluetoothConnection? connection;
  final BluetoothDevice? deviceConnected;

  const JoystickExample({Key? key, this.connection, this.deviceConnected})
      : super(key: key);

  @override
  State<JoystickExample> createState() => _JoystickExampleState();
}

class _JoystickExampleState extends State<JoystickExample> {
  StreamSubscription<List<int>>? _streamSubscription;

  bool _isSendingDireccion = false;
  bool _isSendingVelocidad = false;
  final speedNotifier = ValueNotifier<double>(10);
  final key = GlobalKey<KdGaugeViewState>();
  final receivedDataNotifier =
      ValueNotifier<String>(""); // Notificador para el valor recibido

  void _sendData(int referencia, double data) {
    int remappingInt = 0;

    if (referencia == 1) {
      double remapping = data.remap(-1.00, 1.00, 255, 0);
      remappingInt = remapping.toInt();

      if (_isSendingVelocidad) {
        _isSendingVelocidad = false;

        widget.connection?.output.add(Uint8List.fromList([0x01, remappingInt]));
        ;
        _isSendingVelocidad = true;
        updateSpeedometer(remappingInt);
        setState(() {});
      }
    } else if (referencia == 2) {
      double remapping = data.remap(-1.00, 1.00, 255, 0);
      remappingInt = remapping.toInt();

      if (_isSendingDireccion) {
        _isSendingDireccion = false;

        widget.connection?.output.add(Uint8List.fromList([0x02, remappingInt]));
        ;
        _isSendingDireccion = true;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    // Cancela la suscripción cuando el widget se elimina
    _streamSubscription?.cancel();
    super.dispose();
  }

  void updateSpeedometer(int rawValue) {
    int base = rawValue;
//
    if (base >= 127) {
      // Mover hacia adelante
      base = (base - 127);
      if (base > 100) {
        base = 100;
      }
    } else {
      // Mover hacia atrás
      base = (127 - base);
      if (base > 100) {
        base = 100;
      }
    }

    key.currentState!.updateSpeed(base.toDouble());
    speedNotifier.value = base.toDouble();
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 360,
                  height: 360,
                  padding: const EdgeInsets.all(10),
                  child: ValueListenableBuilder<double>(
                      valueListenable: speedNotifier,
                      builder: (context, value, child) {
                        return KdGaugeView(
                          unitOfMeasurement: " ",
                          speedTextStyle: TextStyle(
                            fontSize: 100,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 6
                              ..color = Colors.black,
                          ),
                          key: key,
                          minSpeed: 0,
                          maxSpeed: 100,
                          speed: 0,
                          animate: true,
                          alertSpeedArray: const [40, 60, 80],
                          alertColorArray: const [
                            Colors.orange,
                            Colors.indigo,
                            Colors.red
                          ],
                          duration: const Duration(seconds: 6),
                        );
                      }),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: JoystickArea(
                            mode: JoystickMode.vertical,
                            initialJoystickAlignment: const Alignment(0, 0.8),
                            listener: (details) {
                              _sendData(1, details.y);
                            },
                            onStickDragStart: () {
                              _isSendingVelocidad = true;
                            },
                            onStickDragEnd: () {
                              _isSendingVelocidad = false;
                            },
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: JoystickArea(
                            mode: JoystickMode.horizontal,
                            initialJoystickAlignment: const Alignment(0, 0.8),
                            listener: (details) {
                              _sendData(2, details.x);
                            },
                            onStickDragStart: () {
                              _isSendingDireccion = true;
                            },
                            onStickDragEnd: () {
                              _isSendingDireccion = false;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.black,
                        onPressed: () => Navigator.of(context)
                            .pop(), // Esto navega al menú anterior
                      ),
                      Text(
                        widget.deviceConnected?.name ?? "######",
                        style: TextStyle(
                          fontFamily: 'Roboto', // Aplicar la fuente Roboto
                          fontSize:
                              16, // Tamaño del texto (puedes ajustar según sea necesario)
                          fontWeight: FontWeight
                              .normal, // Peso de la fuente (normal, bold, etc.)
                          color: Colors.black, // Color del texto
                          // Otros estilos como letterSpacing, fontStyle, etc., si es necesario
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
