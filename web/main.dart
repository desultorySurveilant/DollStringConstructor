import 'dart:html';
import 'dart:convert';
import 'dart:typed_data';

import 'bytebuilder.dart';

void main() {
  Element container = querySelector('#output');

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
  container.appendText('\n');
  NumberInputElement orientationEle = NumberInputElement()
    ..id = 'orientation'
    ..classes.add('spaceAfter')
    ..value = '0';
  container.children.add(orientationEle);
  container.appendText('\n');

  DivElement stuff = DivElement();
  container.append(stuff);
  stuff.text = showValues(container);
  container.appendText('\n');

  calcDollstring();

  ButtonElement update = ButtonElement()
    ..text = 'Update';
  update.onClick.listen((e){
    stuff.text = showValues(container);
    calcDollstring();
  });
  container.append(update);
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
  print(base64Url.encode(bb.toBuffer().asUint8List()));
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
    do{
      if(x >= max){
        ret += '1';
        x -= max;
      }else{
        ret += '0';
      }
      max = (max / 2) as int;
    }while(max > 1);
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