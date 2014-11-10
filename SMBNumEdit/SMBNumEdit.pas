unit SMBNumEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls;

type
  TSMBNumEdit = class(TCustomEdit)
  private
    { Private declarations }
  protected
    procedure KeyPress(var Key: Char); override;
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SMB Components', [TSMBNumEdit]);
end;

{ TSMBNumEdit }

procedure TSMBNumEdit.KeyPress(var Key: Char);
begin
  inherited;
  Key := '!';
end;

end.
