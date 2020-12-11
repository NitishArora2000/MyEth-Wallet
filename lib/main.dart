import 'package:eth_wallet/slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'NAcoin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpclient;
  Web3Client ethclient;
  bool data = false;
  int myamt = 0;
  final myaddress = "0x80C3B9cE2948c0c840ed78F13BD50239dc4a1661";
  var mydata; //save this value in sqflite
  String hashval;

  Future<DeployedContract> loadcontract() async {
    String abi = await rootBundle.loadString("assests/abi.json");
    String contractaddress = "0x8Adc39997273783a1b0a30be84F21D7d846370ca";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "NAcoin"),
        EthereumAddress.fromHex(contractaddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadcontract();
    final ethfunction = contract.function(functionName);
    final result = await ethclient.call(
        contract: contract, function: ethfunction, params: args);
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "37f97ae091d4a638941505e2f7c01071282b7957ed43f61180f98da4cd53be62");
    final contract = await loadcontract();
    final ethfunction = contract.function(functionName);
    final result = await ethclient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethfunction,
          parameters: args,
        ),
        fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<void> getbalance(String targetaddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetaddress);
    List<dynamic> result = await query("getbalance", []);

    mydata = result[0];
    data = true;
    setState(() {});
  }

  Future<String> sendcoin() async {
    var amount = BigInt.from(myamt);

    var response = await submit("depositbalance", [amount]);

    print("deposited");
    hashval = response;
    setState(() {});
    return response;
  }

  Future<String> withdrawcoin() async {
    var amount = BigInt.from(myamt);

    var response = await submit("withdrawbalance", [amount]);

    print("withdrawn");
    hashval = response;
    setState(() {}); //refreshes the UI.
    return response;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpclient = Client();
    ethclient = Web3Client(
        "https://rinkeby.infura.io/v3/b493179f3d6743f891e5971bae67a0e4",
        httpclient);
    getbalance(myaddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ZStack([
          VxBox() //container
              .purple700
              .size(context.screenWidth, context.percentHeight * 13)
              .make(),
          VStack([
            //column
            (context.percentHeight * 4).heightBox,
            "ETH-WALLET".text.xl3.purple100.bold.center.makeCentered().py16(),
            (context.percentHeight * 5).heightBox,
            VxBox(
                    child: VStack([
              "Wallet Balance".text.black.xl2.semiBold.makeCentered(),
              10.heightBox,
              data
                  ? "\₹${mydata}".text.purple500.bold.xl6.makeCentered()
                  : CircularProgressIndicator().centered()
            ]))
                .p16
                .size(context.screenWidth, context.percentHeight * 18)
                .rounded
                .make()
                .p16(), //padding from all sides
            30.heightBox,

            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              //width: 100,
              constraints: BoxConstraints(minWidth: 230.0, minHeight: 25.0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Enter Amount",
                    //fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    fillColor: Colors.green),
                onChanged: (val) {
                  int amount = int.parse(val);
                  if (amount == 0 || amount < 0) {
                    //Dialogbox()
                    // return showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         title: Text("Invalid Amount"),
                    //         actions: [
                    //           FlatButton(
                    //             onPressed: () {
                    //               Navigator.of(context).pop();
                    //             },
                    //             child: "OK".text.make(),
                    //           ),
                    //         ],
                    //       );
                    //     });

                    print("Invalid amount");
                  } else {
                    print("inside");
                    //myamt = (amount * 100).round();
                    myamt = amount;
                    print(myamt);
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                style: new TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
            ),
            // SliderWidget(
            //   min: 0,
            //   max: 100,
            //   finalVal: (value) {
            //     // print("inside");
            //     myamt = (value * 100).round();
            //     print(myamt);
            //   },
            // ).centered().py8(),
            15.heightBox,

            HStack(
              [
                60.widthBox,
                FlatButton.icon(
                        color: Colors.green,
                        onPressed: () => sendcoin(),
                        shape: Vx.roundedSm,
                        icon:
                            Icon(Icons.call_made_outlined, color: Colors.white),
                        label: "Deposit".text.white.make())
                    .h(50),
                20.widthBox,
                FlatButton.icon(
                        color: Colors.red,
                        onPressed: () => withdrawcoin(),
                        shape: Vx.roundedSm,
                        icon: Icon(Icons.call_received, color: Colors.white),
                        label: "Withdraw".text.white.make())
                    .h(50),
              ],
              //alignment: MainAxisAlignment.spaceAround,
              axisSize: MainAxisSize.max, //axis size is minimum as default,
            ).p16(),
            Container(
              alignment: Alignment.center,
              child: FlatButton.icon(
                      color: Colors.blue,
                      onPressed: () => getbalance(myaddress),
                      shape: Vx.roundedSm,
                      icon: Icon(Icons.refresh, color: Colors.white),
                      label: "Refresh".text.white.make())
                  .h(50),
            ),
            30.heightBox,
            if (hashval != null) hashval.text.black.makeCentered().p16(),
          ])
        ]),
      ),
    );
  }
}
