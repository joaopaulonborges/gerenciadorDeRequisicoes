import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_de_requisicao/validators/login_validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequisicaoBloc extends BlocBase with LoginValidators {

  Future _requisicoesPendentes;
  Future _requisicoesAceitas;
  Future _requisicoesNegadas;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future get pendentes => _requisicoesPendentes;
  Future get aceitas => _requisicoesAceitas;
  Future get negadas => _requisicoesNegadas;

  set pendentes (Future value) {
    _requisicoesPendentes = value;
  }
  set aceitas (Future value) {
    _requisicoesAceitas = value;
  }
  set negadas (Future value) {
    _requisicoesNegadas = value;
  }

  RequisicaoBloc();

  iniciaListas(String idUsuario){
    _requisicoesPendentes = recuperarRequsicoes(idUsuario, "pendentes");
    _requisicoesAceitas = recuperarRequsicoes(idUsuario, "aceitas");
    _requisicoesNegadas = recuperarRequsicoes(idUsuario, "negadas");
  }

  Future recuperarRequsicoes(String idUsuario, String tipoRequisicao) async{
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("requisicoes").document(idUsuario).collection(tipoRequisicao).getDocuments();
    return querySnapshot.documents;
  }

  Future recuperarRequsicoesPorData(String idUsuario, String tipoRequisicao, String data) async{
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("requisicoes").document(idUsuario).collection(tipoRequisicao).where("data", isEqualTo: data).getDocuments();
    return querySnapshot.documents;
  }

  Future recuperarRequsicoesPorRazaoSocial(String idUsuario, String tipoRequisicao, String razaosocial) async{
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("requisicoes").document(idUsuario).collection(tipoRequisicao).where("razaosocial", isGreaterThanOrEqualTo: razaosocial).where("razaosocial", isLessThanOrEqualTo : razaosocial+'\uf8ff').getDocuments();
    return querySnapshot.documents;
  }

  @override
  void dispose() {
  }
}