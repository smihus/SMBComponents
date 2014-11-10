unit SMBLabeledEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Windows,
  SMB.Validators, System.Variants;

type
  TValueType            = (vtString, vtInteger, vtFloat);
  TValueConstraintType  = (vctNone, vctGreaterThan, vctGreaterThanOrEqual,
    vctLessThan, vctLessThanOrEqual, vctBetween, vctBetweenOrEqual);

type
  TSMBLabeledEdit = class(TCustomLabeledEdit)
  private
    FIntValue: Integer;
    FFloatValue: Extended;
    FValid: Boolean;
    FErrorMsg: String;
    FFilterInput: Boolean;
    FOnFilterFloatInput: TKeyPressEvent;
    FOnFilterIntegerInput: TKeyPressEvent;
    FOnFilterStringInput: TKeyPressEvent;
    FValueType: TValueType;
    FMin: Extended;
    FMax: Extended;
    FValueConstraint: TValueConstraintType;
    FAutoValidate: Boolean;
    procedure SetFilterInput(const Value: Boolean);
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
    procedure SetValueConstraint(const Value: TValueConstraintType);
    procedure ValidateString;
    procedure ValidateInteger;
    procedure ValidateFloat;
    function GetValid: Boolean;
    procedure SetAutoValidate(const Value: Boolean);
    procedure SetValueType(const Value: TValueType);
    procedure SetMax(const Value: Extended);
    procedure SetMin(const Value: Extended);
    function GetCaption: TCaption;
    procedure SetCaption(const Value: TCaption);
    function GetErrorMsg: String;
  protected
    procedure KeyPress(var Key: Char); override;
    procedure FilterStringInput(var Key: Char); virtual;
    procedure FilterIntegerInput(var Key: Char); virtual;
    procedure FilterFloatInput(var Key: Char); virtual;
    procedure DoValidate(); virtual;
    procedure Change; override;
  public
    {TSMBLabeledEdit}
    property ErrorMsg: String read GetErrorMsg;
    property Valid: Boolean read GetValid;
  published
    property Alignment;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EditLabel;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property LabelPosition;
    property LabelSpacing;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Touch;
    property Visible;
    property StyleElements;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    {TSMBLabeledEdit}
    property FilterInput: Boolean read FFilterInput write SetFilterInput default False;
    property ValueType: TValueType read FValueType write SetValueType default vtString;
    property Value: Variant read GetValue write SetValue;
    property Min: Extended read FMin write SetMin;
    property Max: Extended read FMax write SetMax;
    property ValueConstraint: TValueConstraintType read FValueConstraint write SetValueConstraint default vctNone;
    property AutoValidate: Boolean read FAutoValidate write SetAutoValidate default False;
    property Caption: TCaption read GetCaption write SetCaption;
    {Events}
    property OnFilterFloatInput: TKeyPressEvent read FOnFilterFloatInput write FOnFilterFloatInput;
    property OnFilterIntegerInput: TKeyPressEvent read FOnFilterIntegerInput write FOnFilterIntegerInput;
    property OnFilterStringInput: TKeyPressEvent read FOnFilterStringInput write FOnFilterStringInput;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SMB Components', [TSMBLabeledEdit]);
end;

{ TSMBLabeledEdit }

procedure TSMBLabeledEdit.Change;
begin
  inherited Change;
  if FAutoValidate then DoValidate;
end;

procedure TSMBLabeledEdit.DoValidate;
begin
  FErrorMsg := '';
  case FValueType of
    vtString:   ValidateString;
    vtInteger:  ValidateInteger;
    vtFloat:    ValidateFloat;
  end;
end;

procedure TSMBLabeledEdit.FilterFloatInput(var Key: Char);
begin
  if FFilterInput then
    if Assigned(FOnFilterFloatInput) then
      FOnFilterFloatInput(Self, Key)
    else
      KeyPressFloat(Key);
end;

procedure TSMBLabeledEdit.FilterIntegerInput(var Key: Char);
begin
  if FFilterInput then
    if Assigned(FOnFilterIntegerInput) then
      FOnFilterIntegerInput(Self, Key)
    else
      KeyPressInt(Key);
end;

procedure TSMBLabeledEdit.FilterStringInput(var Key: Char);
begin
  if FFilterInput and Assigned(FOnFilterStringInput) then FOnFilterStringInput(Self, Key);
end;

function TSMBLabeledEdit.GetCaption: TCaption;
begin
  Result := EditLabel.Caption;
end;

function TSMBLabeledEdit.GetErrorMsg: String;
begin
  if not FAutoValidate then DoValidate;
  Result := FErrorMsg;
end;

function TSMBLabeledEdit.GetValid: Boolean;
begin
  if not FAutoValidate then DoValidate;
  Result := FValid;
end;

function TSMBLabeledEdit.GetValue: Variant;
begin
  if not FAutoValidate then DoValidate;
  case FValueType of
    vtString:   Result := Text;
    vtInteger:  Result := FIntValue;
    vtFloat:    Result := FFloatValue;
  end;
end;

procedure TSMBLabeledEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if FFilterInput then
    case FValueType of
      vtString:   FilterStringInput(Key);
      vtInteger:  FilterIntegerInput(Key);
      vtFloat:    FilterFloatInput(Key);
    end;
end;

procedure TSMBLabeledEdit.SetAutoValidate(const Value: Boolean);
begin
  if FAutoValidate <> Value then
  begin
    FAutoValidate := Value;
    if FAutoValidate then DoValidate;
  end;
end;

procedure TSMBLabeledEdit.SetCaption(const Value: TCaption);
begin
  if EditLabel.Caption <> Value then EditLabel.Caption := Value;
end;

procedure TSMBLabeledEdit.SetFilterInput(const Value: Boolean);
begin
  if FFilterInput <> Value then FFilterInput := Value;
end;

procedure TSMBLabeledEdit.SetMax(const Value: Extended);
begin
  if FMax <> Value then
  begin
    FMax := Value;
    if FAutoValidate then DoValidate;
  end;
end;

procedure TSMBLabeledEdit.SetMin(const Value: Extended);
begin
    if FMin <> Value then
  begin
    FMin := Value;
    if FAutoValidate then DoValidate;
  end;
end;

procedure TSMBLabeledEdit.SetValue(const Value: Variant);
var
  StrValue: String;
begin
  StrValue := VarToStr(Value);
  if Text <> StrValue then
  begin
    Text := StrValue;
    Change;
  end;
end;

procedure TSMBLabeledEdit.SetValueConstraint(const Value: TValueConstraintType);
begin
  if FValueConstraint <> Value then
  begin
    FValueConstraint := Value;
    if FAutoValidate then DoValidate;
  end;
end;

procedure TSMBLabeledEdit.SetValueType(const Value: TValueType);
begin
  if FValueType <> Value then
  begin
    FValueType := Value;
    if FAutoValidate then DoValidate;
  end;
end;

procedure TSMBLabeledEdit.ValidateFloat;
begin
  FValid := TryStrToNumMsg(Caption, Text, FErrorMsg, FFloatValue);
  if FValid then
    case FValueConstraint of
      vctNone:                FValid := True;
      vctGreaterThan:         FValid := IsGreaterThan(Caption, FFloatValue, FMin, FErrorMsg);
      vctGreaterThanOrEqual:  FValid := IsGreaterThanOrEqual(Caption, FFloatValue, FMin, FErrorMsg);
      vctLessThan:            FValid := IsLessThan(Caption, FFloatValue, FMax, FErrorMsg);
      vctLessThanOrEqual:     FValid := IsLessThanOrEqual(Caption, FFloatValue, FMax, FErrorMsg);
      vctBetween:             FValid := IsBetween(Caption, FFloatValue, FMin, FMax, FErrorMsg);
      vctBetweenOrEqual:      FValid := IsBetween(Caption, FFloatValue, FMin, FMax, FErrorMsg, True);
    end;
end;

procedure TSMBLabeledEdit.ValidateInteger;
begin
  FValid := TryStrToNumMsg(Caption, Text, FErrorMsg, FIntValue);
  case FValueConstraint of
    vctNone:                FValid := True;
    vctGreaterThan:         FValid := IsGreaterThan(Caption, FIntValue, Trunc(FMin), FErrorMsg);
    vctGreaterThanOrEqual:  FValid := IsGreaterThanOrEqual(Caption, FIntValue, Trunc(FMin), FErrorMsg);
    vctLessThan:            FValid := IsLessThan(Caption, FIntValue, Trunc(FMax), FErrorMsg);
    vctLessThanOrEqual:     FValid := IsLessThanOrEqual(Caption, FIntValue, Trunc(FMax), FErrorMsg);
    vctBetween:             FValid := IsBetween(Caption, FIntValue, Trunc(FMin), Trunc(FMax), FErrorMsg);
    vctBetweenOrEqual:      FValid := IsBetween(Caption, FIntValue, Trunc(FMin), Trunc(FMax), FErrorMsg, True);
  end;
end;

procedure TSMBLabeledEdit.ValidateString;
begin
  case FValueConstraint of
    vctNone:                FValid := True;
    vctGreaterThan:         FValid := IsGreaterThan(Caption, Text, Trunc(FMin), FErrorMsg);
    vctGreaterThanOrEqual:  FValid := IsGreaterThanOrEqual(Caption, Text, Trunc(FMin), FErrorMsg);
    vctLessThan:            FValid := IsLessThan(Caption, Text, Trunc(FMax), FErrorMsg);
    vctLessThanOrEqual:     FValid := IsLessThanOrEqual(Caption, Text, Trunc(FMax), FErrorMsg);
    vctBetween:             FValid := IsBetween(Caption, Text, Trunc(FMin), Trunc(FMax), FErrorMsg);
    vctBetweenOrEqual:      FValid := IsBetween(Caption, Text, Trunc(FMin), Trunc(FMax), FErrorMsg, True);
  end;
end;

end.
