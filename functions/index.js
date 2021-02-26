const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.notificacaoNovaRequisicao = functions.firestore
    .document('requisicoes/{idCliente}/pendentes/{idRequisicao}')
    .onCreate((snap, context) => {
		const documento = snap.data();
		var cliente = context.params.idCliente;
		var id = context.params.idRequisicao;
		var cont = 0;
		var msg = "";
        admin.firestore().collection('token').get().then((snap) => {
            var tokens = [];
            if (snap.empty) {
            }
			else {
                for (var token of snap.docs) {
					if (token.data().idCliente == cliente){
						tokens.push(token.data().token);
                        admin.firestore().collection('requisicoes/'+cliente+'/pendentes').get().then((snap2) => {
                            if (snap2.empty) {
                            }
                            else{
                                for (var requisicao of snap2.docs) {
                                    cont++;
                                }
                            }
                            if(cont==1){
                                msg = "Você tem 1 requisição de pedido pendente";
                            }
                            else{
                                msg = "Você tem "+cont+" requisições de pedido pendentes";
                            }
                            var payload = {
                                "notification": {
                                    "title": "Novo pedido pendente",
                                    "body": msg,
                                    "sound": "default",
                                },
                                "data": {
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "id": id,
                                }
                            }
                            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            }).catch((erro) => {

                            });
                        });
					}
                }
            }
        });
		return Promise.resolve(0);
    });