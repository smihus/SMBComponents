unit SMBLocalSettings;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DBClient, Data.DB, MidasLib, CRTL;

type
  { TSMBLocalSettings компонента, предназначенная для сохранения и получения
    значений. доступ осуществляется как в ассоциативном массиве, где в качестве
    индекса массива используется строковое значение - ключ (название переменной),
    а элемент массива содержит строковое значение.
    Пример использования:
      var
        LS: TSMBLocalSettings;
        FilePath: String;
      begin
        LS := TSMBLocalSettings.Create(Self);  // Вариант №1. будет использоваться
                                    файл settings.xml в корневой папке программы
        LS := TSMBLocalSettings.Init(Self, 'Путь к файлу/имя файла')
                                    // Вариант №2. будет использоваться указанный
                                    путь и имя файла
        Чтение (Вариант №1, предпочтительный)
        FilePath := LS['FilePath']; // при этом проверяется наличие файла с настройками
                                    и наличие сохраненного значения для данного параметра
                                    если файла нет или или параметр еще не сохранен,
                                    то возвращается пустая строка, т.е. '',
                                    иначе возвращается строковое значение этого параметра
        Чтение (Вариант №2, более длинная запись)
        FilePath := LS.Value['FilePath'] // Работает как и предыдущий вариант, просто
                                    запись более длинная
        Запись (Вариант №1, предпочтительный)
        LS['FilePath'] := FilePath; // при этом проверяется наличие параметра,
                                    если параметр есть, то его значение перезаписывается новым,
                                    если параметра нет, то он создается и ему присваевается значение.
        Запись (Вариант №2, более длинная запись)
        LS.Value['FilePath'] := FilePath; // Работает как и предыдущий вариант, просто
                                    запись более длинная
      end; }

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

{ Этот конструктор используется при визуальном расположении компоненты на форму,
  либо когда необходимо чтобы файл с локальными настройками хранился в корневой
  папке программы и назывался settings.xml }

constructor TSMBLocalSettings.Create(AOwner: TComponent);
begin
  Init(AOwner);
end;

{ Этот конструктор может использоваться только при программном создании объекта класса
  и имеет возможность указать путь и название файла локальных настроек }

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
