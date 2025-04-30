import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Widget amb estat per gestionar el xat
class ChatScreen extends StatefulWidget {
  final String ofertaId; // ID de l'oferta a la qual fa referència el xat
  final String empresaId; // ID de l'empresa que ha creat l'oferta
  final String alumneId; // ID de l'alumne amb qui es fa el xat
  final String usuariActualId; // ID de l'usuari que ha iniciat la sessió (autor dels missatges)

  const ChatScreen({
    super.key,
    required this.ofertaId,
    required this.empresaId,
    required this.alumneId,
    required this.usuariActualId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController(); // Controlador pel TextField

  // Stream per escoltar els missatges en temps real (filtrats per oferta, empresa i alumne)
  Stream<QuerySnapshot> _missatgesStream() {
    return FirebaseFirestore.instance
        .collection('missatges_xat')
        .where('ofertaId', isEqualTo: widget.ofertaId)
        .where('empresaId', isEqualTo: widget.empresaId)
        .where('alumneId', isEqualTo: widget.alumneId)
        .orderBy('timestamp') // S'ordena cronològicament
        .snapshots(); // Retorna un flux (stream) que actualitza automàticament quan hi ha nous missatges
  }

  // Funció per enviar un missatge
  Future<void> _enviarMissatge() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // Evita enviar missatges buits

    await FirebaseFirestore.instance.collection('missatges_xat').add({
      'ofertaId': widget.ofertaId,
      'empresaId': widget.empresaId,
      'alumneId': widget.alumneId,
      'autorId': widget.usuariActualId, // Qui ha escrit el missatge
      'text': text,
      'timestamp': FieldValue.serverTimestamp(), // Hora del servidor
    });

    _controller.clear(); // Neteja el camp de text després d'enviar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5, // Línia subtil de separació
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _missatgesStream(),
              builder: (context, snapshot) {
                // En cas d'error a la càrrega de missatges
                if (snapshot.hasError) {
                  print('🔥 Error carregant missatges: ${snapshot.error}');
                  return Center(
                    child: Text('Error carregant dades. Consulta la terminal.'),
                  );
                }

                // Mentres es carreguen dades
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final missatges = snapshot.data!.docs;

                // Llista de missatges mostrats en format xat
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: missatges.length,
                  itemBuilder: (context, index) {
                    final msg = missatges[index].data() as Map<String, dynamic>;
                    final isMe = msg['autorId'] == widget.usuariActualId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft, // Aliniació segons autor
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent.withOpacity(0.8)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16), // Forma del missatge
                        ),
                        child: Text(
                          msg['text'], // Contingut del missatge
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87, // Color del text segons autor
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1), // Separador entre llista i input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escriu un missatge...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _enviarMissatge, // Envia el missatge
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
