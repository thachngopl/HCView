{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{        �ĵ�CheckBoxItem(��ѡ��)����ʵ�ֵ�Ԫ           }
{                                                       }
{*******************************************************}

unit HCCheckBoxItem;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, HCItem, HCRectItem, HCStyle,
  HCCustomData, HCCommon, HCXml;

type
  THCCheckBoxItem = class(THCControlItem)
  private
    FText: string;
    FChecked, FMouseIn: Boolean;
    function GetBoxRect: TRect;
  protected
    procedure SetChecked(const Value: Boolean);
    //
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(const AOwnerData: THCCustomData; const AText: string; const AChecked: Boolean); virtual;
    procedure Assign(Source: THCCustomItem); override;

    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    procedure ToXml(const ANode: IHCXMLNode); override;
    procedure ParseXml(const ANode: IHCXMLNode); override;

    property Checked: Boolean read FChecked write SetChecked;
    property Text: string read FText write FText;
  end;

implementation

uses
  Math;

const
  CheckBoxSize = 14;

{ THCCheckBoxItem }

function THCCheckBoxItem.GetBoxRect: TRect;
begin
  Result := Classes.Bounds(FMargin, (Height - CheckBoxSize) div 2, CheckBoxSize, CheckBoxSize)
end;

procedure THCCheckBoxItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  FChecked := (Source as THCCheckBoxItem).Checked;  // ��ѡ״̬
  FText := (Source as THCCheckBoxItem).Text;
end;

constructor THCCheckBoxItem.Create(const AOwnerData: THCCustomData; const AText: string;
  const AChecked: Boolean);
begin
  inherited Create(AOwnerData);
  Self.StyleNo := THCStyle.CheckBox;
  FChecked := AChecked;
  FText := AText;
  FMouseIn := False;
  FMargin := 2;
end;

procedure THCCheckBoxItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vBoxRect: TRect;
begin
  inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, ACanvas, APaintInfo);
  if FMouseIn and (not APaintInfo.Print) then  // ��������У��ҷǴ�ӡ
  begin
    ACanvas.Brush.Color := clBtnFace;
    ACanvas.FillRect(ADrawRect);
  end;

  vBoxRect := GetBoxRect;
  OffsetRect(vBoxRect, ADrawRect.Left, ADrawRect.Top);

  if Self.IsSelectComplate and (not APaintInfo.Print) then
  begin
    ACanvas.Brush.Color := AStyle.SelColor;
    ACanvas.FillRect(ADrawRect);
  end;

  ACanvas.Brush.Style := bsClear;

  AStyle.TextStyles[TextStyleNo].ApplyStyle(ACanvas, APaintInfo.ScaleY / APaintInfo.Zoom);
  ACanvas.TextOut(ADrawRect.Left + FMargin + CheckBoxSize + FMargin,
    ADrawRect.Top + (Height - ACanvas.TextHeight('H')) div 2, FText);

  if FChecked then  // ��ѡ
  begin
    //ACanvas.Font.Size := 10;
    //ACanvas.TextOut(vBoxRect.Left, vBoxRect.Top, '��');
    DrawFrameControl(ACanvas.Handle, vBoxRect, DFC_MENU, DFCS_CHECKED or DFCS_MENUCHECK)
    //DrawFrameControl(ACanvas.Handle, vBoxRect, DFC_BUTTON, DFCS_CHECKED or DFCS_BUTTONCHECK);
  end;
  //else
  //  DrawFrameControl(ACanvas.Handle, vBoxRect, DFC_BUTTON, DFCS_HOT or DFCS_BUTTONCHECK);

  if FMouseIn and (not APaintInfo.Print) then  // ��������У��ҷǴ�ӡ
  begin
    ACanvas.Pen.Color := clBlue;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
    InflateRect(vBoxRect, 1, 1);
    ACanvas.Pen.Color := clBtnFace;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
  end
  else  // ��겻�����л��ӡ
  begin
    ACanvas.Pen.Color := clBlack;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
  end;
end;

procedure THCCheckBoxItem.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);
var
  vSize: TSize;
begin
  if Self.AutoSize then
  begin
    ARichData.Style.ApplyTempStyle(TextStyleNo);
    vSize := ARichData.Style.TempCanvas.TextExtent(FText);
    Width := FMargin + CheckBoxSize + FMargin + vSize.cx;  // ���
    Height := Max(vSize.cy, CheckBoxSize);
  end;

  if Width < FMinWidth then
    Width := FMinWidth;
  if Height < FMinHeight then
    Height := FMinHeight;
end;

procedure THCCheckBoxItem.MouseEnter;
begin
  inherited MouseEnter;
  FMouseIn := True;
end;

procedure THCCheckBoxItem.MouseLeave;
begin
  inherited MouseLeave;
  FMouseIn := False;
end;

procedure THCCheckBoxItem.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  //if PtInRect(GetBoxRect, Point(X, Y)) then
  GCursor := crArrow;
end;

procedure THCCheckBoxItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if PtInRect(GetBoxRect, Point(X, Y)) then  // �����˹�ѡ����
    Checked := not FChecked;
end;

procedure THCCheckBoxItem.ParseXml(const ANode: IHCXMLNode);
begin
  inherited ParseXml(ANode);
  FChecked := ANode.Attributes['check'];
  FText := ANode.Text;
end;

procedure THCCheckBoxItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FChecked, SizeOf(FChecked));  // ����ѡ״̬
  HCLoadTextFromStream(AStream, FText);  // ��Text
end;

procedure THCCheckBoxItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  AStream.WriteBuffer(FChecked, SizeOf(FChecked));  // �湴ѡ״̬
  HCSaveTextToStream(AStream, FText);
end;

procedure THCCheckBoxItem.SetChecked(const Value: Boolean);
begin
  if FChecked <> Value then
  begin
    FChecked := Value;
  end;
end;

procedure THCCheckBoxItem.ToXml(const ANode: IHCXMLNode);
begin
  inherited ToXml(ANode);
  ANode.Attributes['check'] := FChecked;  // �湴ѡ״̬
  ANode.Text := FText;
end;

end.
