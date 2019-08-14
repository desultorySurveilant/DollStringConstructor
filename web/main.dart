import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'bytebuilder.dart';

void main() {
  Element container = querySelector('#output');
  Random rand = Random();

  TextInputElement nameEle = TextInputElement()
    ..id = 'name'
    ..classes.add('spaceAfter')
    ..value = 'test+name';
  container.children.add(nameEle);
  container.appendText('\n');
  TextInputElement labelPlate = TextInputElement()
    ..id = 'labelPlate'
    ..classes.add('spaceAfter')
    ..value = ':___';
  container.children.add(labelPlate);
  container.appendText('\n');

  NumberInputElement typeEle = NumberInputElement()
    ..id = 'type'
    ..classes.add('spaceAfter')
    ..value = '1';
  container.children.add(typeEle);
  container.appendText('\n');
  NumberInputElement paletteLength = NumberInputElement()
    ..id = 'paletteLength'
    ..classes.add('spaceAfter')
    ..value = '3';
  container.children.add(paletteLength);
  DivElement colorInput = DivElement()
    ..id = 'colorInput'
    ..classes.add('spaceAfter')
    ..classes.add('inputList');
  container.children.add(colorInput);
  paletteLength.onChange.listen((e){
    resetInput(paletteLength, '#colorInput', 'color');
  });
  InputElement color;
  for(int i = 0; i < int.parse(paletteLength.value); i++){
    color = InputElement()
      ..type = 'color'
      ..classes.add('inputBox')
      ..value = '#000000';
    colorInput.children.add(color);
  }

  NumberInputElement layerLength = NumberInputElement()
    ..id = 'layerLength'
    ..classes.add('spaceAfter')
    ..value = '5';
  container.children.add(layerLength);
  DivElement layerInput = DivElement()
    ..id = 'layerInput'
    ..classes.add('spaceAfter')
    ..classes.add('inputList');
  container.children.add(layerInput);
  layerLength.onChange.listen((e){
    resetInput(layerLength, '#layerInput', 'number');
  });
  InputElement layer;
  for(int i = 0; i < int.parse(layerLength.value); i++){
    layer = NumberInputElement()
      ..classes.add('inputBox')
      ..value = '$i';
    layerInput.children.add(layer);
  }

  NumberInputElement rotationEle = NumberInputElement()
    ..id = 'rotation'
    ..classes.add('spaceAfter')
    ..value = '0';
  container.children.add(rotationEle);
  ButtonElement randRot = ButtonElement()
    ..text = 'Randomize';
  randRot.onClick.listen((e){
    rotationEle.value = rand.nextInt(360).toString();
  });
  container.children.add(randRot);
  container.appendText('\n');
  NumberInputElement orientationEle = NumberInputElement()
    ..id = 'orientation'
    ..classes.add('spaceAfter')
    ..value = '0';
  container.children.add(orientationEle);
  ButtonElement randOri = ButtonElement()
    ..text = 'Randomize';
  randOri.onClick.listen((e){
    orientationEle.value = rand.nextInt(4).toString();
  });
  container.children.add(randOri);
  container.appendText('\n');

  DivElement stuff = DivElement();
  container.append(stuff);
  stuff.text = showValues(container);
  container.appendText('\n');

  DivElement dollstring = DivElement()
    ..classes.add('spaceAfter');
  container.append(dollstring);
  dollstring.text = calcDollstring();
  container.appendText('\n');

  ButtonElement update = ButtonElement()
    ..text = 'Update'
    ..classes.add('spaceAfter');
  update.onClick.listen((e){
    stuff.text = showValues(container);
    dollstring.text = calcDollstring();
  });
  container.append(update);
  container.appendText('\n');

  TextInputElement loadString = TextInputElement()
    ..id = 'loadString'
    ..classes.add('spaceAfter')
//    ..classes.add('big')
    ..value = 'Paste Here';
  container.children.add(loadString);
  ButtonElement load = ButtonElement()
    ..text = 'Load Doll';
  container.children.add(load);
  load.onClick.listen((e){
    loadDoll();
  });
}

loadDoll(){
  String ds = ie('loadString').value;
  print(ds);
  ds = replacePercents(ds);
  print(ds);
  ie('name').value = ds.substring(0, ds.indexOf(':'));
  ie('labelPlate').value = ':___';
  ds = ds.split(':___')[1];
  ImprovedByteReader br = ImprovedByteReader(base64Decode(ds).buffer);
  ie('type').value = br.readExpGolomb().toString();
  ie('paletteLength').value = br.readExpGolomb().toString();
  querySelector('#colorInput').children.clear();
  for(int i = 0; i < int.parse(ie('paletteLength').value); i++){
    InputElement color = InputElement()
      ..type = 'color'
      ..classes.add('inputBox');
    String tempString = '#';
    tempString += hexify(br.readByte());
    tempString += hexify(br.readByte());
    tempString += hexify(br.readByte());
    color.value = tempString;
    querySelector('#colorInput').children.add(color);
  }
  ie('layerLength').value = br.readExpGolomb().toString();
  querySelector('#layerInput').children.clear();
  for(int i = 0; i < int.parse(ie('layerLength').value); i++){
    InputElement layer = InputElement()
      ..type = 'number'
      ..classes.add('inputBox');
    layer.value = br.readExpGolomb().toString();
    querySelector('#layerInput').children.add(layer);
  }
  ie('rotation').value = br.readExpGolomb().toString();
  ie('orientation').value = br.readExpGolomb().toString();
}

calcDollstring(){
  ByteBuilder bb = ByteBuilder();
  InputElement nameEle = querySelector('#name');
  InputElement labelPlate = querySelector('#labelPlate');
  bb.appendExpGolomb(getEleIntVal('#type'));
  bb.appendExpGolomb(getEleIntVal('#paletteLength'));
  for(InputElement ie in querySelector('#colorInput').children){
    bb.appendBits(hexToInt(ie.value.substring(1)), 24);
  }
  bb.appendExpGolomb(getEleIntVal('#layerLength'));
  for(InputElement ie in querySelector('#layerInput').children){
    bb.appendExpGolomb(int.parse(ie.value));
  }
  bb.appendExpGolomb(getEleIntVal('#rotation'));
  bb.appendExpGolomb(getEleIntVal('#orientation'));
  print('${nameEle.value}${labelPlate.value}');
  print(toBytes(bb.toBuffer().asUint8List()));
  ByteBuilder.prettyPrintByteBuffer(bb.toBuffer());
  print(base64Url.encode(bb.toBuffer().asUint8List()));
  print('${nameEle.value}${labelPlate.value}${base64Url.encode(bb.toBuffer().asUint8List())}');
  return '${nameEle.value}${labelPlate.value}${base64Url.encode(bb.toBuffer().asUint8List())}';
}
resetInput(NumberInputElement LengthElement, String id, String type){
  print('reseting an input');
  InputElement color;
  DivElement ci = querySelector(id);
  ci.children.clear();
  for(int i = 0; i < int.parse(LengthElement.value); i++){
    color = InputElement()
      ..type = type
      ..classes.add('inputBox')
      ..value = '$i';
    ci.children.add(color);
  }
}

String showValues(container){
  String ret = '';
  ret += 'Type: ${getEleIntVal('#type')}\n';
  ret += 'Palette Length: ${getEleIntVal('#paletteLength')}\n';
  ret += showValFromInputBox(querySelector('#colorInput'), 'Color');
  ret += 'Layer Length: ${getEleIntVal('#layerLength')}\n';
  ret += showValFromInputBox(querySelector('#layerInput'), 'Layer');
  ret += 'Rotation: ${getEleIntVal('#rotation')}\n';
  ret += 'Orientation: ${getEleIntVal('#orientation')}\n';
  return ret;
}
showValFromInputBox(Element e, String stuff){
  String ret = '';
  int count = 0;
  for(InputElement ie in e.children){
    ret += '${stuff} ${count}: ${ie.value}\n';
    count++;
  }
  return ret;
}

getEleIntVal(String id) => int.parse(getEleVal(id));
getEleVal(String id){
  InputElement e = querySelector(id);
  return e.value;
}

hexToInt(String str){
  int ret = 0;
  for(int i = 0; i < str.length -1; i++){
    ret += singleHexToInt(str.substring(i, i+1));
    ret *= 16;
  }
  ret += singleHexToInt(str.substring(str.length-1, str.length));
  return ret;
}
singleHexToInt(String s){
  if(s == 'f')return 15;
  else if(s == 'e')return 14;
  else if(s == 'd')return 13;
  else if(s == 'c')return 12;
  else if(s == 'b')return 11;
  else if(s == 'a')return 10;
  else return int.parse(s);
}
toBytes(Uint8List l){
  String ret = '';
  int max = 128;
  for(int x in l){
    max = 128;
    while(max > 1){
      if(x >= max){
        ret += '1';
        x -= max;
      }else{
        ret += '0';
      }
      max = (max / 2) as int;
    }
    if(x >= max){
      ret += '1';
      x -= max;
    }else{
      ret += '0';
    }
    ret += ' ';
  }
  return ret;
}
String hexify(int n){
  String ret = '';
    ret += singleHexify((n as int) ~/ 16);
    ret += singleHexify((n as int) %16);
  return ret;
}
String singleHexify(int n){
  if(n==15)return 'f';
  else if(n==14)return 'e';
  else if(n==13)return 'd';
  else if(n==12)return 'c';
  else if(n==11)return 'b';
  else if(n==10)return 'a';
  else return n.toString();
}
String replacePercents(String str){
  while(str.contains('%')){
    if(str.contains('%2C'))str = str.split('%2C')[0] + ',' + str.split('%2C')[1];
    if(str.contains('%3A'))str = str.split('%3A')[0] + ':' + str.split('%3A')[1];
    if(str.contains('%3D'))str = str.split('%3D')[0] + '=' + str.split('%3D')[1];
  }
  return str;
}
ie(String s) => querySelector('#$s') as InputElement;