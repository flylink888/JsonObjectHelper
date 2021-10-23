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
  Memo2.Lines.Add('ִ��' + SpinEdit1.Value.ToString + '�Σ�����: ' +
    inttostr(MilliSecondsBetween(T, now)) + ' ms');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  jo: TJSONObject;
begin
  jo := TJSONObject.Create;
  try
    jo.AddPair('name', '�Ŵ�˳');
    jo.AddPair('age', TJSONNumber.Create(40));
    jo.AddPair('married', TJSONBool.Create(True));
    jo.AddPair('books', TJSONArray.Create.Add('��Web������Ա�ο���ȫ��')
      .Add('��delphi���ѧϰ��'));
    jo.AddPair('organization', TJSONObject.Create.AddPair('oname', '���л��Ƽ�')
      .AddPair('oyear', TJSONNumber.Create(20)));
    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free; // �м�������Ҫ�ͷ�
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  jo: TJSONObject;
begin
  jo := TJSONObject.Create;
  try
    jo.S['name'] := '�Ŵ�˳';
    jo.i['age'] := 40;
    jo.B['married'] := True;
    jo.A['books'] := TJSONArray.Create;
    jo.A['books'].Add('��Web������Ա�ο���ȫ��').Add('��delphi���ѧϰ��');

    jo.O['organization'] := TJSONObject.Create;
    jo.O['organization'].S['oname'] := '���л��Ƽ�';
    jo.O['organization'].i['oyear'] := 20;
    jo.D['date'] := now;
    {
      //Ҳ�������£�
      jo.O['organization'] := TJSONObject.Create.AddPair('oname','���л��Ƽ�');
      jo.O['organization'].I['oyear'] := 20;
    }
    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free; // �м�������Ҫ�ͷ�
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
    // ��ȡ����
    name := jo.S['name']; // �Ŵ�˳
    // married := jo.B['married']; // true
    bookname := jo.A['books'].Items[0].ToString; // ��Web������Ա�ο���ȫ��

    oname := jo.O['organization'].S['oname']; // '���л��Ƽ�';
    age := jo.O['organization'].i['oyear']; // 20;
    ShowMessage(name + ' ' + inttostr(age));
  finally
    jo.Free; // �м�������Ҫ�ͷ�
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  jo: TJSONObject;
begin
  jo := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  if jo = nil then
  begin
    // ����ʧ�ܣ�����JSON��ʽ���ַ���
    Exit;
  end;
  try
    // ɾ��name
    // jo.Remove('name'); // ֱ��������Ҫɾ������Ŀ�������û�м�free����Ϊhelper����Ѿ�����
    // Ҳ����ʹ��������䣬ע��һ��Ҫ����free�����������ڴ�й¶
    // jo.RemovePair('name').Free;    //����ԭ�����÷�
    // ɾ����������Ŀ
    jo.A['books'].Remove(0).Free; // ɾ�������еĵ�һ���Web������Ա�ο���ȫ��

    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free; // �м�������Ҫ�ͷ�
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  jo: TJSONObject;
  ja: TJSONArray;
begin
  jo := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  if jo = nil then // ���jo����JSON����ֱ���˳�
    Exit;
  ja := TJSONArray.Create;
  try
    ja.Add('����һ���ַ���');
    ja.Add(1024); // ��������1024
    ja.Add(False); // ���Ӳ���ֵ False
    ja.Add(TJSONObject.Create.AddPair('street', 'st 208')); // ֱ������һ������
    jo.AddPair('����', ja);
    Memo2.Text := jo.ToString; // JSON_Format(jo.ToString);
  finally
    jo.Free;
    // ע�� ja ����Ҫ�ͷţ���Ϊ���ͷ� jo��ʱ��ϵͳ���Զ��ͷ�
  end;

end;

procedure TForm1.Button9Click(Sender: TObject);
var
  jo: TJSONObject;
  ja: TJSONArray;
  i: Byte;
begin
  ja := TJSONArray.Create; // �����������
  try
    for i := 1 to 3 do
    begin
      jo := TJSONObject.Create; // ��������Ԫ�أ���JSON����
      jo.S['name'] := 'sensor' + i.ToString;
      jo.i['index'] := i;
      ja.Add(jo); // ������Ԫ�����ӵ�������
    end;
    Memo2.Text := ja.ToJSON; // JSON_Fromat_Array(ja);
  finally
    ja.Free; // ע�� jo ����Ҫ�ͷţ���Ϊ���ͷ� ja��ʱ��ϵͳ���Զ��ͷ�
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
    jo.S['Name'] := 'sensor11'; // �ظ��ֶΣ����������һ��Ϊ׼

    jo.i['age'] := 54;
    jo.i['age'] := 154;

    jo.D['birth'] := now;
    jo.B['worked'] := False;
    jo.i['money'] := $7FF1F2F3F4F5F6F7;
    jo.i['xx'] := 100;
    jo.RemovePair('age').Free; // ɾ���������Ǽ����ͣ�Ҳ��Ҫʹ��Free����������ڴ�й¶

    // jo.O['OBJ'] := TJSONObject.Create;
    jo.O['OBJ'].S['AAAA'] := '1200';

    jo.O['jjoo11'] := jo1;
    jo1.AddPair('ABC', 'ABC1000');
    jo1.AddPair('ABB', 'ABC2000');

    jo.A['ArrayDemo'] := TJSONArray.Create;;
    jo.A['ArrayDemo'].Add('�й�');
    jo.A['ArrayDemo'].Add(100);
    jo.A['ArrayDemo'].Add('wwww');
    jo.A['ArrayDemo'].Add('true').Add('�㶫ʡ').Add(False);

    jo.A['ArrayDemo'].Remove(3).Free; // ɾ���������Ǽ����ͣ�Ҳ��Ҫʹ��Free����������ڴ�й¶
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
