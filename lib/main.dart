
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main(){
  runApp(
      const MyApp()
  );
}

void IniciarConexion(String usuarioID) async{

  final user = User(id: usuarioID, extraData: {
    "name": usuarioID,
    "image": "[object Object]",
  });

  final client = StreamChatClient(
    "hnv9kent5jf5",
    logLevel: Level.INFO,
    connectTimeout: Duration(milliseconds: 6000),
    receiveTimeout: Duration(milliseconds: 6000),
  );


  await client.connectUser(user, client.devToken(usuarioID).rawValue);
 // client.deleteChannel("testChannel_" + usuarioID, "messaging");
 // final channel = client.channel('messaging', id:"Channel_" + usuarioID);
  final channel = client.channel(
    "messaging",
    id: "Channel_" + usuarioID,
    extraData: {
      "name": "Channel_" + usuarioID,
    },
  );
  channel.watch();
  //channel.query();
  //channel.delete();
 // client.deleteChannel("testChannel", "messaging");

  /*Filter filter = {
    "type": "messaging",
    "members": {
      "\$in": [usuarioID]
    }
  } as Filter;

  final channels = await client.queryChannels(
    filter: filter,
    sort: [SortOption("last_message_at", direction: SortOption.DESC)],
    watch: true,
    state: true,
  );*/

  runApp( Index(
    client: client,
    userID: usuarioID,
  )
  );
}

class MyApp extends StatelessWidget {
 // final Channel channel;

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //home:  ChannelListPage(userID: userID,),
      //  home: UsersListPage(),
          home: MyHomePage(title: 'Login',),
    );
  }
}

class Index extends StatelessWidget{
  final StreamChatClient client;
  final String userID;
  const Index({Key? key, required this.client,/* required this.channel,*/ required this.userID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context,child){
        return StreamChat(
            client: client,
            child: child);
      },
      home:  ChannelListPage(userID: userID,),
    );
  }
}

class ChannelPage extends StatelessWidget{
  const ChannelPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  ChannelHeader(
      ),
      body: Column(
        children:  [
          Expanded(
              child: MessageListView(
                threadBuilder: (_, parentMessage) {
                  return ThreadPage(
                    parent: parentMessage,
                  );
                },
              )
          ),
          const MessageInput(),
        ],
      ),
    );
  }
}

class ChannelListPage extends StatelessWidget{
  const ChannelListPage({Key? key, required this.userID}) : super(key: key);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title:  const Text("Hello!")
      ),
      body: ChannelsBloc(
        child: ChannelListView(
         // filter: Filter.in_('members', [StreamChat.of(context).currentUser!.id]),
          sort: const [SortOption('last_message_at')],
          channelWidget: const ChannelPage(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  UsersListPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ThreadPage extends StatelessWidget{
  const ThreadPage({Key? key, this.parent}) : super(key: key);
  final Message? parent;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: ThreadHeader(parent: parent!,),
      body: Column(children: [
        Expanded(
            child: MessageListView(
              parentMessage: parent,
            ),
        ),
         MessageInput(
          parentMessage: parent,
        )
      ],),
    );
  }

}

class UsersListPage extends StatelessWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:  const Text("Contactos")
      ),
      body: UsersBloc(
        child: UserListView(
          filter: Filter.notEqual('id', StreamChat.of(context).user!.id),
          sort: const [
            SortOption(
              'name',
              direction: 1,
            ),
          ],
         /* onUserTap: (user,_){
            final channel = client.channel(
              "messaging",
              id: "Channel_" + usuarioID,
              extraData: {
                "name": "Channel_" + usuarioID,
              },
            );
            channel.watch();
          },*/
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String user;

  final textUserController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.login),
                title: Text('Bienvenido!'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: TextField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Ingresa tu nombre',
                  ),
                  controller: textUserController,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                 Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                     child: ElevatedButton(
                         onPressed: () {
                            if(textUserController.text.isNotEmpty){
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  MyApp()),
                              );*/
                              IniciarConexion(textUserController.text);
                            }
                         },
                         child: const Text('Entrar')
                     ),
                 ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
