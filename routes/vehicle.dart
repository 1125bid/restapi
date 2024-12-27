import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
//data key 값이 userId , value값이 vehicleNumber

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
        "vehicleNumbers": [
          vehicleNumber // 등록된 차량 번호 리스트
        ],
      },
    );
  }
  //차량번호 등록
  if (method == HttpMethod.post) {
    try {
      final body = await context.request.body();
      final decodedBody = jsonDecode(body);
      final userId = decodedBody['userId'];
      if (userId == null) {
        return Response(statusCode: 400);
      }
      final vehicleNumber = decodedBody["vehicleNumber"];
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
        body: {'차량번호': vehicleNumber},
      );
    } catch (e) {
      print(e);
      return Response.json(statusCode: 400);
    }
  }
  //차량번호 수정
  if (method == HttpMethod.patch) {
    return Response.json(body: {
      "vehicleNumbers": [
        "11가1111" // 등록된 차량 번호 리스트
      ]
    });
  }
  print(context.request.method.value);
  return Response.json(body: {
    "name": "김진용",
  });
}
