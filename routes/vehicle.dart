import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
//data key 값이 userId , value값이 vehicleNumber

//mockdata
final data = {"1": "11가1111"};

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  //차량번호 조회
  if (method == HttpMethod.get) {
    final body = await context.request.body();
    print(body);
    final decodedBody = jsonDecode(body);
    final userId = decodedBody['userId'];
    if (userId == null) {
      return Response(statusCode: 400);
    }
    final vehicleNumber = data[userId];
    if (vehicleNumber == null) {
      return Response(statusCode: 404);
    }
    //request body에서 useId 갖고오기 중복확인.
    //번호판이 있으면 번호판을 리턴하고 없으면 statuscode:404
    return Response.json(
      body: {
        'vehicleNumber': [
          vehicleNumber // 등록된 차량 번호 리스트
        ],
      },
    );
  }
  //차량번호 등록
  if (method == HttpMethod.post) {
    try {
      //차량번호 정보와 유저 아이디 갖고오기
      final body = await context.request.body();
      final decodedBody = jsonDecode(body);
      final userId = decodedBody['userId'];
      if (userId == null) {
        return Response(statusCode: 400);
      }
      final vehicleNumber = decodedBody['vehicleNumber'];
      if (vehicleNumber == null) {
        return Response(statusCode: 400);
      }
      // 사용자의 번호판이 이미 (타인 또는 나)등록되어있으면 response status code: 409(conflict)
      if (data.containsValue(vehicleNumber)) {
        return Response(statusCode: 409);
      }
      // 그게 아니라면 map["userId"]에 요청 받은 vehicle번호ß를 넣어준다.
      data[userId.toString()] = vehicleNumber.toString();
      return Response.json(
        statusCode: 201,
        body: {'vehicleNumber': vehicleNumber},
      );
    } catch (e) {
      print(e);
      return Response.json(statusCode: 400);
    }
  }
  //차량번호 수정
  if (method == HttpMethod.patch) {
    //유저 아이디 갖고오기
    final body = await context.request.body();
    final decodedBody = jsonDecode(body);
    final userId = decodedBody['userId'];
    //유저 아이디가 없는 경우
    if (userId == null) {
      return Response(statusCode: 400);
    }
    //차량번호 갖고오기
    final vehicleNumber = decodedBody['vehicleNumber'];
    //차량번호가 없는 경우
    if (vehicleNumber == null) {
      return Response(statusCode: 400);
    }
// 사용자의 번호판이 이미 (타인 또는 나)등록되어있으면 response status code: 409(conflict)
    if (data.containsValue(vehicleNumber)) {
      return Response(statusCode: 409);
    }
    //string 타입으로 지정. 데이터 값에 수정한 데이터 값 넣기
    data[userId.toString()] = vehicleNumber.toString();
    return Response.json(
      body: {
        'vehicleNumber': [
          vehicleNumber.toString() //  변경할 차량 번호 리스트
        ]
      },
    );
  }
  //차량번호 삭제
  if (method == HttpMethod.delete) {
    //유저 아이디 갖고오기
    final body = await context.request.body();
    final decodedBody = jsonDecode(body);
    final userId = decodedBody['userId'];
    //유저 아이디가 없는 경우
    if (userId == null) {
      return Response(statusCode: 400);
    }
    //차량번호 갖고오기
    final vehicleNumber = decodedBody['vehicleNumber'];
    //차량번호가 없는 경우
    if (vehicleNumber == null) {
      return Response(statusCode: 400);
    }
    //useId의 데이터 값이 request 받은 vehicleNumber와 같은지 확인.
    if (data[userId] != vehicleNumber) {
      return Response(statusCode: 409);
    }
//userId 통해서 차량번호 삭제
    data.remove(userId);
    return Response.json(
      body: {
        'vehicleNumber': [
          vehicleNumber.toString() //  삭제된 번호판
        ],
      },
    );
  }
  print(context.request.method.value);
  return Response(statusCode: 405);
}
