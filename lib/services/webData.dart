import 'dart:io';

import 'dart:async';
import 'dart:convert';


class WebData{

  List data = [];


  Future fetchData(String url) async {

    new HttpClient().getUrl(Uri.parse(url))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) => response.transform(new Utf8Decoder()).listen(print));

   /* final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    }
    else {
      throw Exception('Failed to load data');
    }*/

/*      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> values = [];
      values = jsonDecode(response.body);
      print(values);
      if(values.length>0){
        for(int i=0;i<values.length;i++){
          if(values[i]!=null){
            Map<String,dynamic> map=values[i];
            data.add(map);
            debugPrint('Id-------${map['id']}');
          }
        }
      }
      return data;
    }
    else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }*/
  }
}