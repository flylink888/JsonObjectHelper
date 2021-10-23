# JsonObjectHelper
JSONObject Helper Class


implify json usage on delphi 10.1 and above



  var
  
  JSON := TJsonObject.Create;
  
  try
  
  if JSON.Load('{"a":[0,1], "b":"Hello"}') then
  
  begin
  
    JSON.StrPath['c.d.e'] := '...';
    
    JSON.BoolPath['a[0].ff'] := false;
    
    showmessage(JSON.Dump);
    
  end;
  
  finally
  
  JSON.Free;
  
  end;
  
  
  
  
  or:
  
  
  
var
  jo, jo1: TJSONObject;
begin
  jo := TJSONObject.Create;
  jo1 := TJSONObject.Create;
  try
    jo.S['Name'] := 'sensor';
    jo.S['Name'] := 'sensor11'; // 重复字段，内容以最后一个为准

    jo.i['age'] := 54;
    jo.i['age'] := 154;

    jo.D['birth'] := now;
    jo.B['worked'] := False;
    jo.i['money'] := $7FF1F2F3F4F5F6F7;
    jo.i['xx'] := 100;
    jo.RemovePair('age').Free; // 删除的哪怕是简单类型，也需要使用Free，否则会有内存泄露

    // jo.O['OBJ'] := TJSONObject.Create;
    jo.O['OBJ'].S['AAAA'] := '1200';

    jo.O['jjoo11'] := jo1;
    jo1.AddPair('ABC', 'ABC1000');
    jo1.AddPair('ABB', 'ABC2000');

    jo.A['ArrayDemo'] := TJSONArray.Create;;
    jo.A['ArrayDemo'].Add('中国');
    jo.A['ArrayDemo'].Add(100);
    jo.A['ArrayDemo'].Add('wwww');
    jo.A['ArrayDemo'].Add('true').Add('广东省').Add(False);

    jo.A['ArrayDemo'].Remove(3).Free; // 删除的哪怕是简单类型，也需要使用Free，否则会有内存泄露
    jo.Remove('jjoo11');
    Result := jo.ToString;
  finally
    jo.Free;
  end;
  
  
  
  
