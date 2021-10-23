{ **************************************
  功能: Delphi原生JSON Helper类防JsonDateObjects
  作者：janlei
  时间：2021-10-23
  ************************************** }
unit uJsonValueHelper;

interface

uses
  System.Json, System.SysUtils
{$IFDEF MSWINDOWS}
    , Windows
{$ENDIF}
    ;

type
  TJSONArrayHelper = class Helper for System.Json.TJSONArray
  private
    procedure SetArrayItem(const index: Integer; const NewValue: TJSONValue);
  public
    procedure Clear;
    property I[const index: Integer]: TJSONValue write SetArrayItem;
  end;

  TJSONPairHelper = class Helper for System.Json.TJSONPair
  private
    function GetName: String;
    function GetCount: Integer;
  public
    function AsArr: TJSONArray;
    function AsObj: TJsonObject;
    function AsBool: Boolean;
    function AsFloat: Double;
    function AsInt: Int64;
    function AsStr: String;
    property Name: String read GetName;
    property Count: Integer read GetCount;
  end;

  TJSONObjectHelper = class Helper for System.Json.TJsonObject
  private
    procedure SetBoolean(const Key: string; const Value: Boolean);
    procedure SetF(const Key: string; const Value: Double);
    procedure SetInt64(const Key: string; const Value: Int64);
    procedure SetS(const Key, Value: string);
    procedure SetObject(const Key: string; const Value: TJsonObject);
    procedure SetArray(const Key: string; const Value: TJSONArray);
    procedure SetBooleanP(const Path: string; const Value: Boolean);
    procedure SetFPath(const Path: string; const Value: Double);
    procedure SetInt64P(const Path: string; const Value: Int64);
    procedure SetStringP(const Path, Value: string);
    procedure SetObjectP(const Path: string; const Value: TJsonObject);
    procedure SetArrayP(const Path: string; const Value: TJSONArray);
    function GetS(const Key: string): string;
    function GetB(const Key: string): Boolean;
    function GetI(const Key: string): Int64;
    function GetD(const Key: string): TDateTime;
    procedure SetD(const Key: string; const Value: TDateTime);
    function ForcePath(const Path: string; out Name: String; out index: Integer)
      : TJSONValue;
  public
    function Load(const Value: string): Boolean;
    function Exist(const Key: string): Boolean;
    function ExistPath(const Path: string): Boolean;
    procedure Remove(const Key: string);
    function Dump: string;

    function GetBool(const Key: string; const Default: Boolean = False)
      : Boolean;
    function GetFloat(const Key: string; const Default: Double = 0)
      : Double; overload;
    function GetFloat(const Key: string; const Default: Single = 0)
      : Single; overload;
    function GetInt(const Key: string; const Default: Integer = 0)
      : Integer; overload;
    function GetInt(const Key: string; const Default: Int64 = 0)
      : Int64; overload;
    function GetStr(const Key: string; const Default: string = ''): string;

    function GetBoolPath(const Path: string;
      const Default: Boolean = False): Boolean;
    function GetFloatPath(const Path: string; const Default: Double = 0)
      : Double; overload;
    function GetFloatPath(const Path: string; const Default: Single = 0)
      : Single; overload;
    function GetIntPath(const Path: string; const Default: Integer = 0)
      : Integer; overload;
    function GetIntPath(const Path: string; const Default: Int64 = 0)
      : Int64; overload;
    function GetStrPath(const Path: string; const Default: string = ''): string;

    function AddArray(const Key: string): TJSONArray;
    function AddObject(const Key: string): TJsonObject;
    function GetArray(const Key: string): TJSONArray;
    function GetObject(const Key: string): TJsonObject;

    function AddArrayP(const Path: string): TJSONArray;
    function AddObjectP(const Path: string): TJsonObject;
    function GetArrayP(const Path: string): TJSONArray;
    function GetBPath(const Path: string): Boolean;
    function GetFPath(const Path: string): Double;
    function GetIPath(const Path: string): Int64;
    function GetObjectP(const Path: string): TJsonObject;
    function GetSPath(const Path: string): string;
    class function JSONToDateTime(const Value: string;
      ConvertToLocalTime: Boolean = True): TDateTime; static;
    class function DateTimeToJSON(const Value: TDateTime; UseUtcTime: Boolean)
      : string; static;
    class function UtcDateTimeToJSON(const UtcDateTime: TDateTime)
      : string; static;

    property S[const Key: string]: string read GetS write SetS;
    property I[const Key: string]: Int64 read GetI write SetInt64;
    property F[const Key: string]: Double write SetF;
    property B[const Key: string]: Boolean read GetB write SetBoolean;
    property O[const Key: string]: TJsonObject read GetObject write SetObject;
    property A[const Key: string]: TJSONArray read GetArray write SetArray;
    property D[const Key: string]: TDateTime read GetD write SetD;

    property SPath[const Path: string]: string read GetSPath write SetStringP;
    property IPath[const Path: string]: Int64 read GetIPath write SetInt64P;
    property FPath[const Path: string]: Double read GetFPath write SetFPath;
    property BPath[const Path: string]: Boolean read GetBPath write SetBooleanP;
    property OPath[const Path: string]: TJsonObject read GetObjectP
      write SetObjectP;
    property APath[const Path: string]: TJSONArray read GetArrayP
      write SetArrayP;
  end;

implementation

{$IFDEF MSWINDOWS}
{$IFDEF SUPPORT_WINDOWS2000}

var
  TzSpecificLocalTimeToSystemTime
    : function(lpTimeZoneInformation: PTimeZoneInformation;
    var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;

function TzSpecificLocalTimeToSystemTimeWin2000(lpTimeZoneInformation
  : PTimeZoneInformation; var lpLocalTime, lpUniversalTime: TSystemTime)
  : BOOL; stdcall;
var
  TimeZoneInfo: TTimeZoneInformation;
begin
  if lpTimeZoneInformation <> nil then
    TimeZoneInfo := lpTimeZoneInformation^
  else
    GetTimeZoneInformation(TimeZoneInfo);

  // Reverse the bias so that SystemTimeToTzSpecificLocalTime becomes TzSpecificLocalTimeToSystemTime
  TimeZoneInfo.Bias := -TimeZoneInfo.Bias;
  TimeZoneInfo.StandardBias := -TimeZoneInfo.StandardBias;
  TimeZoneInfo.DaylightBias := -TimeZoneInfo.DaylightBias;

  Result := SystemTimeToTzSpecificLocalTime(@TimeZoneInfo, lpLocalTime,
    lpUniversalTime);
end;
{$ELSE}
function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation
  : PTimeZoneInformation; var lpLocalTime, lpUniversalTime: TSystemTime): BOOL;
  stdcall; external kernel32 name 'TzSpecificLocalTimeToSystemTime';
{$ENDIF SUPPORT_WINDOWS2000}
{$ENDIF MSWINDOWS}
{$IFDEF USE_NAME_STRING_LITERAL}

procedure InitializeJsonMemInfo;
var
  MemInfo: TMemoryBasicInformation;
begin
  JsonMemInfoInitialized := True;
  if VirtualQuery(PByte(HInstance + $1000), MemInfo, SizeOf(MemInfo))
    = SizeOf(MemInfo) then
  begin
    JsonMemInfoBlockStart := MemInfo.AllocationBase;
    JsonMemInfoBlockEnd := JsonMemInfoBlockStart + MemInfo.RegionSize;
  end;
  if HInstance <> MainInstance then
  begin
    if VirtualQuery(PByte(MainInstance + $1000), MemInfo, SizeOf(MemInfo))
      = SizeOf(MemInfo) then
    begin
      JsonMemInfoMainBlockStart := MemInfo.AllocationBase;
      JsonMemInfoMainBlockEnd := JsonMemInfoMainBlockStart + MemInfo.RegionSize;
    end;
  end;
end;
{$ENDIF USE_NAME_STRING_LITERAL}

function UtcDateTimeToLocalDateTime(UtcDateTime: TDateTime): TDateTime;
{$IFDEF MSWINDOWS}
var
  UtcTime, LocalTime: TSystemTime;
begin
  DateTimeToSystemTime(UtcDateTime, UtcTime);
  if SystemTimeToTzSpecificLocalTime(nil, UtcTime, LocalTime) then
    Result := SystemTimeToDateTime(LocalTime)
  else
    Result := UtcDateTime;
end;
{$ELSE}

begin
  Result := TTimeZone.Local.ToLocalTime(UtcDateTime);
end;
{$ENDIF MSWINDOWS}

function ParseDateTimePart(P: PChar; var Value: Integer;
  MaxLen: Integer): PChar;
var
  V: Integer;
begin
  Result := P;
  V := 0;
  while CharInset(Result^, ['0' .. '9']) and (MaxLen > 0) do
  begin
    V := V * 10 + (Ord(Result^) - Ord('0'));
    Inc(Result);
    Dec(MaxLen);
  end;
  Value := V;
end;

function LocalDateTimeToUtcDateTime(DateTime: TDateTime): TDateTime;
{$IFDEF MSWINDOWS}
var
  UtcTime, LocalTime: TSystemTime;
begin
  DateTimeToSystemTime(DateTime, LocalTime);
  if TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
    Result := SystemTimeToDateTime(UtcTime)
  else
    Result := DateTime;
end;
{$ELSE}

begin
  Result := TTimeZone.Local.ToUniversalTime(DateTime);
end;
{$ENDIF MSWINDOWS}

function DateTimeToISO8601(Value: TDateTime): string;
{$IFDEF MSWINDOWS}
var
  LocalTime, UtcTime: TSystemTime;
  Offset: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  DateTimeToSystemTime(Value, LocalTime);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d',
    [LocalTime.wYear, LocalTime.wMonth, LocalTime.wDay, LocalTime.wHour,
    LocalTime.wMinute, LocalTime.wSecond, LocalTime.wMilliseconds]);
  if TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
  begin
    Offset := Value - SystemTimeToDateTime(UtcTime);
    DecodeTime(Offset, Hour, Min, Sec, MSec);
    if Offset < 0 then
      Result := Format('%s-%.2d:%.2d', [Result, Hour, Min])
    else if Offset > 0 then
      Result := Format('%s+%.2d:%.2d', [Result, Hour, Min])
    else
      Result := Result + 'Z';
  end;
end;
{$ELSE}

var
  Offset: TDateTime;
  Year, Month, Day, Hour, Minute, Second, Milliseconds: Word;
begin
  DecodeDate(Value, Year, Month, Day);
  DecodeTime(Value, Hour, Minute, Second, Milliseconds);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d',
    [Year, Month, Day, Hour, Minute, Second, Milliseconds]);
  Offset := Value - TTimeZone.Local.ToUniversalTime(Value);
  DecodeTime(Offset, Hour, Minute, Second, Milliseconds);
  if Offset < 0 then
    Result := Format('%s-%.2d:%.2d', [Result, Hour, Minute])
  else if Offset > 0 then
    Result := Format('%s+%.2d:%.2d', [Result, Hour, Minute])
  else
    Result := Result + 'Z';
end;
{$ENDIF MSWINDOWS}

class function TJSONObjectHelper.JSONToDateTime(const Value: string;
  ConvertToLocalTime: Boolean): TDateTime;
var
  P: PChar;
  MSecsSince1970: Int64;
  Year, Month, Day, Hour, Min, Sec, MSec: Integer;
  OffsetHour, OffsetMin: Integer;
  Sign: Double;
begin
  Result := 0;
  if Value = '' then
    Exit;

  P := PChar(Value);
  if (P^ = '/') and (StrLComp('Date(', P + 1, 5) = 0) then
  // .NET: milliseconds since 1970-01-01
  begin
    Inc(P, 6);
    MSecsSince1970 := 0;
    while (P^ <> #0) and CharInset(P^, ['0' .. '9']) do
    begin
      MSecsSince1970 := MSecsSince1970 * 10 + (Ord(P^) - Ord('0'));
      Inc(P);
    end;
    if (P^ = '+') or (P^ = '-') then // timezone information
    begin
      Inc(P);
      while (P^ <> #0) and CharInset(P^, ['0' .. '9']) do
        Inc(P);
    end;
    if (P[0] = ')') and (P[1] = '/') and (P[2] = #0) then
    begin
      Result := UnixDateDelta + (MSecsSince1970 / MSecsPerDay);
      if ConvertToLocalTime then
        Result := UtcDateTimeToLocalDateTime(Result);
    end
    else
      Result := 0; // invalid format
  end
  else
  begin
    // "2015-02-01T16:08:19.202Z"
    if P^ = '-' then // negative year
      Inc(P);
    P := ParseDateTimePart(P, Year, 4);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Month, 2);
    if P^ <> '-' then
      Exit; // invalid format
    P := ParseDateTimePart(P + 1, Day, 2);

    Hour := 0;
    Min := 0;
    Sec := 0;
    MSec := 0;
    Result := EncodeDate(Year, Month, Day);

    if P^ = 'T' then
    begin
      P := ParseDateTimePart(P + 1, Hour, 2);
      if P^ <> ':' then
        Exit; // invalid format
      P := ParseDateTimePart(P + 1, Min, 2);
      if P^ = ':' then
      begin
        P := ParseDateTimePart(P + 1, Sec, 2);
        if P^ = '.' then
          P := ParseDateTimePart(P + 1, MSec, 3);
      end;
      Result := Result + EncodeTime(Hour, Min, Sec, MSec);
      if (P^ <> 'Z') and (P^ <> #0) then
      begin
        if (P^ = '+') or (P^ = '-') then
        begin
          if P^ = '+' then
            Sign := -1 // +0100 means that the time is 1 hour later than UTC
          else
            Sign := 1;

          P := ParseDateTimePart(P + 1, OffsetHour, 2);
          if P^ = ':' then
            Inc(P);
          ParseDateTimePart(P, OffsetMin, 2);

          Result := Result + (EncodeTime(OffsetHour, OffsetMin, 0, 0) * Sign);
        end
        else
        begin
          Result := 0; // invalid format
          Exit;
        end;
      end;

      if ConvertToLocalTime then
        Result := UtcDateTimeToLocalDateTime(Result);
    end;
  end;
end;

class function TJSONObjectHelper.DateTimeToJSON(const Value: TDateTime;
  UseUtcTime: Boolean): string;
{$IFDEF MSWINDOWS}
var
  LocalTime, UtcTime: TSystemTime;
begin
  if UseUtcTime then
  begin
    DateTimeToSystemTime(Value, LocalTime);
    if not TzSpecificLocalTimeToSystemTime(nil, LocalTime, UtcTime) then
      UtcTime := LocalTime;
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%dZ',
      [UtcTime.wYear, UtcTime.wMonth, UtcTime.wDay, UtcTime.wHour,
      UtcTime.wMinute, UtcTime.wSecond, UtcTime.wMilliseconds]);
  end
  else
    Result := DateTimeToISO8601(Value);
end;
{$ELSE}

begin
  if UseUtcTime then
    Result := UtcDateTimeToJSON(TTimeZone.Local.ToUniversalTime(Value))
  else
    Result := DateTimeToISO8601(Value);
end;
{$ENDIF MSWINDOWS}

class function TJSONObjectHelper.UtcDateTimeToJSON(const UtcDateTime
  : TDateTime): string;
var
  Year, Month, Day, Hour, Minute, Second, Milliseconds: Word;
begin
  DecodeDate(UtcDateTime, Year, Month, Day);
  DecodeTime(UtcDateTime, Hour, Minute, Second, Milliseconds);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%dZ',
    [Year, Month, Day, Hour, Minute, Second, Milliseconds]);
end;

function TJSONObjectHelper.AddArray(const Key: string): TJSONArray;
begin
  Result := TJSONArray.Create;
  AddPair(Key, Result);
end;

function TJSONObjectHelper.AddArrayP(const Path: string): TJSONArray;
begin
  Result := TJSONArray.Create;
  SetArrayP(Path, Result);
end;

function TJSONObjectHelper.AddObject(const Key: string): TJsonObject;
begin
  Result := TJsonObject.Create;
  AddPair(Key, Result);
end;

function TJSONObjectHelper.AddObjectP(const Path: string): TJsonObject;
begin
  Result := TJsonObject.Create;
  SetObjectP(Path, Result);
end;

procedure TJSONObjectHelper.Remove(const Key: string);
begin
  RemovePair(Key).Free;
end;

function TJSONObjectHelper.Dump: string;
begin
  Result := ToString;
end;

function TJSONObjectHelper.Exist(const Key: string): Boolean;
begin
  Result := Assigned(GetValue(Key));
end;

function TJSONObjectHelper.ExistPath(const Path: string): Boolean;
begin
  Result := FindValue(Path) <> nil;
end;

function TJSONObjectHelper.ForcePath(const Path: string; out Name: String;
  out index: Integer): TJSONValue;
var
  LParser: TJSONPathParser;
  LCurrentValue: TJSONValue;
var
  I: Integer;
begin
  if (Self = nil) or (Path = '') then
    Exit(Self);
  Result := nil;
  LParser := TJSONPathParser.Create(Path);
  LCurrentValue := Self;
  while not LParser.IsEof do
  begin
    case LParser.NextToken of
      TJSONPathParser.TToken.Name:
        begin
          if LCurrentValue.ClassType <> TJsonObject then
          begin
            LCurrentValue := TJsonObject.Create;
            if Result.ClassType = TJsonObject then
            begin
              TJsonObject(Result).RemovePair(Name);
              TJsonObject(Result).AddPair(Name, LCurrentValue);
            end
            else
            begin
              TJSONArray(Result).I[Index] := LCurrentValue;
            end;
          end;
          Result := LCurrentValue;
          Name := LParser.TokenName;
          LCurrentValue := TJsonObject(LCurrentValue).Values[LParser.TokenName];
          if LCurrentValue = nil then
          begin
            LCurrentValue := TJSONNull.Create;
            TJsonObject(Result).AddPair(LParser.TokenName, LCurrentValue);
          end;
        end;
      TJSONPathParser.TToken.ArrayIndex:
        begin
          if LCurrentValue.ClassType <> TJSONArray then
          begin
            LCurrentValue := TJSONArray.Create;
            if Result.ClassType = TJsonObject then
            begin
              TJsonObject(Result).RemovePair(Name);
              TJsonObject(Result).AddPair(Name, LCurrentValue);
            end
            else
            begin
              TJSONArray(Result).I[Index] := LCurrentValue;
            end;
          end;
          for I := 0 to LParser.TokenArrayIndex -
            TJSONArray(LCurrentValue).Count do
          begin
            TJSONArray(LCurrentValue).AddElement(TJSONNull.Create);
          end;
          Result := LCurrentValue;
          Index := LParser.TokenArrayIndex;
          LCurrentValue := TJSONArray(LCurrentValue)
            .Items[LParser.TokenArrayIndex];
        end;
      TJSONPathParser.TToken.Error, TJSONPathParser.TToken.Undefined:
        Exit;
      TJSONPathParser.TToken.Eof:
        ;
    end;
  end;
end;

function TJSONObjectHelper.GetArray(const Key: string): TJSONArray;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) and (V is TJSONArray) then
    Result := V as TJSONArray
  else
  begin
    // Result := nil;
    Result := TJSONArray.Create;
    AddPair(Key, Result);
  end;
end;

function TJSONObjectHelper.GetArrayP(const Path: string): TJSONArray;
var
  V: TJSONValue;
begin
  V := FindValue(Path);
  if Assigned(V) and (V is TJSONArray) then
    Result := V as TJSONArray
  else
    Result := nil;
end;

function TJSONObjectHelper.GetB(const Key: string): Boolean;
begin
  Result := GetBool(Key);
end;

function TJSONObjectHelper.GetObject(const Key: string): TJsonObject;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) and (V is TJsonObject) then
    Result := V as TJsonObject
  else
  begin
    // Result := nil;
    Result := TJsonObject.Create;
    AddPair(Key, Result);
  end;
end;

function TJSONObjectHelper.GetObjectP(const Path: string): TJsonObject;
var
  V: TJSONValue;
begin
  V := FindValue(Path);
  if Assigned(V) and (V is TJsonObject) then
    Result := V as TJsonObject
  else
    Result := nil;
end;

function TJSONObjectHelper.GetStr(const Key, Default: string): string;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    Result := V.GetValue<string>()
  end
  else
    Result := Default;
end;

function TJSONObjectHelper.GetStrPath(const Path: string;
  const Default: string = ''): string;
begin
  Result := GetValue<string>(Path, Default);
end;

procedure TJSONObjectHelper.SetBoolean(const Key: string; const Value: Boolean);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, TJSONBool.Create(Value));
end;

procedure TJSONObjectHelper.SetBooleanP(const Path: string;
  const Value: Boolean);
var
  Name: String;
  index: Integer;
  LValue: TJSONValue;
begin
  LValue := ForcePath(Path, Name, Index);
  if LValue <> nil then
    if LValue.ClassType = TJsonObject then
    begin
      TJsonObject(LValue).SetBoolean(Name, Value);
    end
    else if LValue.ClassType = TJSONArray then
    begin
      TJSONArray(LValue).I[Index] := TJSONBool.Create(Value);
    end;
end;

procedure TJSONObjectHelper.SetF(const Key: string; const Value: Double);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, TJSONNumber.Create(Value));
end;

procedure TJSONObjectHelper.SetFPath(const Path: string; const Value: Double);
var
  Name: String;
  index: Integer;
  LValue: TJSONValue;
begin
  LValue := ForcePath(Path, Name, Index);
  if LValue <> nil then
    if LValue.ClassType = TJsonObject then
    begin
      TJsonObject(LValue).SetF(Name, Value);
    end
    else if LValue.ClassType = TJSONArray then
    begin
      TJSONArray(LValue).I[Index] := TJSONNumber.Create(Value);
    end;
end;

procedure TJSONObjectHelper.SetInt64(const Key: string; const Value: Int64);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, TJSONNumber.Create(Value));
end;

procedure TJSONObjectHelper.SetInt64P(const Path: string; const Value: Int64);
var
  Name: String;
  index: Integer;
  LValue: TJSONValue;
begin
  LValue := ForcePath(Path, Name, Index);
  if LValue <> nil then
    if LValue.ClassType = TJsonObject then
    begin
      TJsonObject(LValue).SetInt64(Name, Value);
    end
    else if LValue.ClassType = TJSONArray then
    begin
      TJSONArray(LValue).I[Index] := TJSONNumber.Create(Value);
    end;
end;

procedure TJSONObjectHelper.SetArray(const Key: string;
  const Value: TJSONArray);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, Value);
end;

procedure TJSONObjectHelper.SetArrayP(const Path: string;
  const Value: TJSONArray);
var
  Name: String;
  index: Integer;
  LValue: TJSONValue;
begin
  LValue := ForcePath(Path, Name, Index);
  if LValue <> nil then
    if LValue.ClassType = TJsonObject then
    begin
      TJsonObject(LValue).SetArray(Name, Value);
    end
    else if LValue.ClassType = TJSONArray then
    begin
      TJSONArray(LValue).I[Index] := Value;
    end;
end;

procedure TJSONObjectHelper.SetObject(const Key: string;
  const Value: TJsonObject);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, Value);
end;

procedure TJSONObjectHelper.SetObjectP(const Path: string;
  const Value: TJsonObject);
var
  Name: String;
  index: Integer;
  LValue: TJSONValue;
begin
  LValue := ForcePath(Path, Name, Index);
  if LValue <> nil then
    if LValue.ClassType = TJsonObject then
    begin
      TJsonObject(LValue).SetObject(Name, Value);
    end
    else if LValue.ClassType = TJSONArray then
    begin
      TJSONArray(LValue).I[Index] := Value;
    end;
end;

procedure TJSONObjectHelper.SetS(const Key, Value: string);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, Value);
end;

procedure TJSONObjectHelper.SetStringP(const Path, Value: string);
var
  Name: String;
  index: Integer;
  LValue: TJSONValue;
begin
  LValue := ForcePath(Path, Name, Index);
  if LValue <> nil then
    if LValue.ClassType = TJsonObject then
    begin
      TJsonObject(LValue).SetS(Name, Value);
    end
    else if LValue.ClassType = TJSONArray then
    begin
      TJSONArray(LValue).I[Index] := TJSONString.Create(Value);
    end;
end;

function TJSONObjectHelper.GetBool(const Key: string;
  const Default: Boolean): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    Result := V.GetValue<Boolean>()
  end
  else
    Result := Default;
end;

function TJSONObjectHelper.GetBoolPath(const Path: string;
  const Default: Boolean = False): Boolean;
begin
  Result := GetValue<Boolean>(Path, Default);
end;

function TJSONObjectHelper.GetBPath(const Path: string): Boolean;
begin
  Result := GetBoolPath(Path);
end;

function TJSONObjectHelper.GetD(const Key: string): TDateTime;
begin
  Result := JSONToDateTime(GetStr(Key));
end;

function TJSONObjectHelper.GetFloat(const Key: string;
  const Default: Double): Double;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    Result := V.GetValue<Double>()
  end
  else
    Result := Default;
end;

function TJSONObjectHelper.GetFloat(const Key: string;
  const Default: Single): Single;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    Result := V.GetValue<Single>()
  end
  else
    Result := Default;
end;

function TJSONObjectHelper.GetFloatPath(const Path: string;
  const Default: Double = 0): Double;
begin
  Result := GetValue<Double>(Path, Default);
end;

function TJSONObjectHelper.GetFloatPath(const Path: string;
  const Default: Single): Single;
begin
  Result := GetValue<Single>(Path, Default);
end;

function TJSONObjectHelper.GetFPath(const Path: string): Double;
begin
  Result := GetFloatPath(Path, 0);
end;

function TJSONObjectHelper.GetI(const Key: string): Int64;
begin
  Result := GetInt(Key, 0);
end;

function TJSONObjectHelper.GetInt(const Key: string;
  const Default: Integer): Integer;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    Result := V.GetValue<Integer>()
  end
  else
    Result := Default;
end;

function TJSONObjectHelper.GetInt(const Key: string;
  const Default: Int64): Int64;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    Result := V.GetValue<Int64>()
  end
  else
    Result := Default;
end;

function TJSONObjectHelper.GetIntPath(const Path: string;
  const Default: Integer = 0): Integer;
begin
  Result := GetValue<Integer>(Path, Default);
end;

function TJSONObjectHelper.GetIntPath(const Path: string;
  const Default: Int64): Int64;
begin
  Result := GetValue<Int64>(Path, Default);
end;

function TJSONObjectHelper.GetIPath(const Path: string): Int64;
begin
  Result := GetInt(Path, 0);
end;

function TJSONObjectHelper.GetS(const Key: string): string;
begin
  Result := GetStr(Key);
end;

function TJSONObjectHelper.GetSPath(const Path: string): string;
begin
  Result := GetStrPath(Path);
end;

function TJSONObjectHelper.Load(const Value: string): Boolean;
var
  V: TArray<Byte>;
begin
  V := TEncoding.UTF8.GetBytes(Value);
  Result := Parse(V, 0) > 0;
end;

procedure TJSONObjectHelper.SetD(const Key: string; const Value: TDateTime);
begin
  if Exist(Key) then
    RemovePair(Key).Free;
  AddPair(Key, DateTimeToJSON(Value, True));
end;

{ TJSONArrayHelper }

procedure TJSONArrayHelper.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    Remove(I);
end;

procedure TJSONArrayHelper.SetArrayItem(const index: Integer;
  const NewValue: TJSONValue);
begin
  with Self do
  begin
    FElements.Items[Index].Free;
    FElements.Items[Index] := NewValue;
  end;
end;

{ TJSONPairHelper }

function TJSONPairHelper.AsArr: TJSONArray;
begin
  if JsonValue is TJSONArray then
    Result := JsonValue as TJSONArray
  else
    Result := nil;
end;

function TJSONPairHelper.AsBool: Boolean;
begin
  Result := JsonValue.GetValue<Boolean>();
end;

function TJSONPairHelper.AsFloat: Double;
begin
  Result := JsonValue.GetValue<Double>();
end;

function TJSONPairHelper.AsInt: Int64;
begin
  Result := JsonValue.GetValue<Int64>();
end;

function TJSONPairHelper.AsObj: TJsonObject;
begin
  if JsonValue is TJsonObject then
    Result := JsonValue as TJsonObject
  else
    Result := nil;
end;

function TJSONPairHelper.AsStr: String;
begin
  Result := JsonValue.GetValue<String>();
end;

function TJSONPairHelper.GetCount: Integer;
begin
  if JsonValue.ClassType = TJsonObject then
  begin
    Result := TJsonObject(JsonValue).Count;
  end
  else if JsonValue.ClassType = TJSONArray then
  begin
    Result := TJSONArray(JsonValue).Count;
  end
  else
  begin
    Result := 0;
  end;
end;

function TJSONPairHelper.GetName: String;
begin
  Result := JsonString.Value;
end;

end.
