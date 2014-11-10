unit SMBLocalSettings;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DBClient, Data.DB;

type
  TSMBLocalSettings = class(TComponent)
  private
    FClientDataSet: TClientDataSet;
    function GetValue(const Key: string): String;
    procedure SetValue(const Key: string; const Value: String);
  public
    constructor Create(AOwner: TComponent); override;
    constructor Init(AOwner: TComponent; const AFileName: String = '');
    destructor Destroy; override;
    property Value[const Key: string]: String read GetValue write SetValue; default;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SMB Components', [TSMBLocalSettings]);
end;

{ TSMBLocalSettings }

constructor TSMBLocalSettings.Create(AOwner: TComponent);
begin
  Init(AOwner);
end;

constructor TSMBLocalSettings.Init(AOwner: TComponent; const AFileName: String = '');
var
  FileExist: Boolean;
begin
  inherited Create(AOwner);
  FClientDataSet := TClientDataSet.Create(Self);
  with FClientDataSet do
  begin
    if AFileName = '' then
      FileName := GetCurrentDir + '\settings.xml'
    else
      FileName := AFileName;

    FileExist := FileExists(FileName);
    if FileExist then
    begin
      LoadFromFile;
      if not (Assigned(FindField('Key')) and Assigned(FindField('Value'))) then
        FieldDefs.Clear;
    end;

    if not FileExist or (FieldDefs.Count = 0) then
    begin
      FieldDefs.Add('Key',    TFieldType.ftString, 100, True);
      FieldDefs.Add('Value',  TFieldType.ftString, 100, True);
      Active := False;
      CreateDataSet;
      Active := True;
    end;
  end;
end;

destructor TSMBLocalSettings.Destroy;
begin
  FClientDataSet.Free;
  inherited Destroy;
end;

function TSMBLocalSettings.GetValue(const Key: string): String;
begin
  with FClientDataSet do
    if Locate('Key', Key, [loPartialKey]) then
      Result := FieldByName('Value').AsString
    else
      Result := ''
end;

procedure TSMBLocalSettings.SetValue(const Key, Value: String);
begin
  with FClientDataSet do
    if Locate('Key', Key, [loPartialKey]) then
    begin
      Edit;
      FieldByName('Value').AsString := Value;
      Post;
    end
    else
    begin
      Append;
      FieldByName('Key').AsString   := Key;
      FieldByName('Value').AsString := Value;
      Post;
    end;
end;
end.
