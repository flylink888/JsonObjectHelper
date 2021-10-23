unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Forms, Dialogs,
  System.JSON,
  System.DateUtils, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.Samples.Spin;

type

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    SpinEdit1: TSpinEdit;
    Panel1: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    JSONStr: string;

    function Create_JSON: string;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses uJsonValueHelper;
// uses uSZHN_JSON;

procedure TForm1.Button1Click(Sender: TObject);
var
  S: string;
begin
  S := Create_JSON;
  Memo2.Text := S; // JSON_Format( S );
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
  S: string;
  T: TDateTime;
begin
  T := now;
  for i := 0 to SpinEdit1.Value - 1 do
  begin
    S := Create_JSON;
  end;
  Memo2.Text := S; // JSON_Format(S);
  Memo2.Lines.Add('执行' + SpinEdit1.Value.ToString + '次，花费: ' +
    inttostr(MilliSecondsBetween(T, now)) + ' ms');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  jo: TJSONObject;
begin
  jo := TJSONObject.Create;
  try
    jo.AddPair('name', '张大顺');
    jo.AddPair('age', TJSONNumber.Create(40));
    jo.AddPair('married', TJSONBool.Create(True));
    jo.AddPair('books', TJSONArray.Create.Add('《Web开发人员参考大全》')
      .Add('《delphi深度学习》'));
    jo.AddPair('organization', TJSONObject.Create.AddPair('oname', '大中华科技')
      .AddPair('oyear', TJSONNumber.Create(20)));
    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free; // 切记这里需要释放
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  jo: TJSONObject;
begin
  jo := TJSONObject.Create;
  try
    jo.S['name'] := '张大顺';
    jo.i['age'] := 40;
    jo.B['married'] := True;
    jo.A['books'] := TJSONArray.Create;
    jo.A['books'].Add('《Web开发人员参考大全》').Add('《delphi深度学习》');

    jo.O['organization'] := TJSONObject.Create;
    jo.O['organization'].S['oname'] := '大中华科技';
    jo.O['organization'].i['oyear'] := 20;
    jo.D['date'] := now;
    {
      //也可以如下：
      jo.O['organization'] := TJSONObject.Create.AddPair('oname','大中华科技');
      jo.O['organization'].I['oyear'] := 20;
    }
    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free; // 切记这里需要释放
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  jo: TJSONObject;
  name: string;
  age: integer;
  // married: Boolean;
  bookname: string;
  oname: string;
begin
  // jo := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  jo := TJSONObject.Create;
  try
    jo.Load(JSONStr);
    // 获取姓名
    name := jo.S['name']; // 张大顺
    // married := jo.B['married']; // true
    bookname := jo.A['books'].Items[0].ToString; // 《Web开发人员参考大全》

    oname := jo.O['organization'].S['oname']; // '大中华科技';
    age := jo.O['organization'].i['oyear']; // 20;
    ShowMessage(name + ' ' + inttostr(age));
  finally
    jo.Free; // 切记这里需要释放
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  jo: TJSONObject;
begin
  jo := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  if jo = nil then
  begin
    // 解析失败，不是JSON格式的字符串
    Exit;
  end;
  try
    // 删除name
    // jo.Remove('name'); // 直接输入需要删除的项目名，这句没有加free是因为helper里边已经加了
    // 也可以使用下面语句，注意一定要加上free，否则会产生内存泄露
    // jo.RemovePair('name').Free;    //这是原生的用法
    // 删除数组中项目
    jo.A['books'].Remove(0).Free; // 删除数组中的第一项：《Web开发人员参考大全》

    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free; // 切记这里需要释放
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  jo: TJSONObject;
  ja: TJSONArray;
begin
  jo := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  if jo = nil then // 如果jo不是JSON对象，直接退出
    Exit;
  ja := TJSONArray.Create;
  try
    ja.Add('增加一个字符串');
    ja.Add(1024); // 增加数字1024
    ja.Add(False); // 增加布尔值 False
    ja.Add(TJSONObject.Create.AddPair('street', 'st 208')); // 直接增加一个对象
    jo.AddPair('数组', ja);
    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free;
    // 注意 ja 不需要释放，因为在释放 jo的时候系统会自动释放
  end;

end;

procedure TForm1.Button9Click(Sender: TObject);
var
  jo: TJSONObject;
  ja: TJSONArray;
  i: Byte;
begin
  ja := TJSONArray.Create; // 创建数组对象
  try
    for i := 1 to 3 do
    begin
      jo := TJSONObject.Create; // 创建数组元素，是JSON对象
      jo.S['name'] := 'sensor' + i.ToString;
      jo.i['index'] := i;
      ja.Add(jo); // 将数组元素增加到数组中
    end;
    Memo2.Text := ja.ToJSON; // JSON_Fromat_Array(ja);
  finally
    ja.Free; // 注意 jo 不需要释放，因为在释放 ja的时候系统会自动释放
  end;
end;

function TForm1.Create_JSON: string;
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
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  JSONStr := Memo1.Text;
end;

end.
