import 'dart:convert';
import 'dart:html';

import 'package:home_brewery_website/api/models/login_response.dart';
import 'package:home_brewery_website/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Auth {

  Future<String> getJwtAsync() async {
    print("Start getting jwt.");
    var sharedPreferences = await SharedPreferences.getInstance();
    var jwt = sharedPreferences.getString("jwt");
    jwt ??= "";
    print("End getting jwt. ($jwt)");
    return jwt;
  }

  Future setJwtAsync(String jwt) async {
    print("Start setting jwt. ($jwt)");
    var sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("jwt", jwt);
    print("Set jwt. ($jwt)");
  }

  Future deleteJwtAsync() async {
    print("Start deleting jwt.");
    var sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("jwt");
    print("Removed jwt.");
  }

  Future<User> fetchCurrentUserAsync(String jwt) async {
    print("Start getting current user. With jwt $jwt");
    var uri = Uri.parse("${Constants.baseUrl}/Users/GetCurrent");
    var response = await http.get(uri, headers: {"Authorization": "Bearer $jwt"});

    if (response.statusCode == HttpStatus.ok) {
      var user = User.fromJson(jsonDecode(response.body));
      print("Got current user. (${response.body})");
      return user;
    } else {
      print("Can't get current user. Code ${response.statusCode}");
      return User(id: 0, email: "");
    }
  }

  Future<BaseResponse> loginAsync(String email, String password) async {
    print("Start login");
    var uri = Uri.parse("${Constants.baseUrl}/Auth/Login/$email, $password");
    var response = await http.get(uri);
    if(response.statusCode == HttpStatus.ok){
      var jwt = jsonDecode(response.body)["token"].toString();
      await setJwtAsync(jwt);
      print("Logged in $email. Jwt $jwt");
    }
    print("End login $email. Status ${response.statusCode}");
    return BaseResponse(statusCode: response.statusCode, body: response.body);
  }

  Future<BaseResponse> registerAsync(String email, String password) async {
    print("Start register $email");
    var uri = Uri.parse("${Constants.baseUrl}/Auth/Register");
    var response = await http.post(uri, body: jsonEncode({"email": email, "password": password}), headers: headers);
    print("End register $email");
    return BaseResponse(statusCode: response.statusCode, body: response.body);
  }

  static Map<String, String> headers = {
    "Content-type": "application/json",
    "Accept": "application/json"
  };
}
