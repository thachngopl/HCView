{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  �ĵ�������ʵ�ֵ�Ԫ                   }
{                                                       }
{*******************************************************}

unit HCScrollBar;

interface

uses
  Windows, Classes, Controls, Graphics;

const
  ButtonSize = 20;

type
  TOrientation = (oriHorizontal, oriVertical);

  TScrollCode = (scLineUp, scLineDown, scPageUp, scPageDown, scPosition,
    scTrack, scTop, scBottom, scEndScroll);

  TScrollEvent = procedure(Sender: TObject; ScrollCode: TScrollCode;
    const ScrollPos: Integer) of object;

  TBarControl = (cbcBar, cbcLeftBtn, cbcThum, cbcRightBtn);

  THCScrollBar = class(TGraphicControl)  // Ϊʵ�ֹ������ϰ����϶����ؼ���Ҳ�ܼ�������,ʹ�� SetCapture ��Ҫ���
  private
    /// <summary> ������λ�õ���Сֵ </summary>
    FMin,
    /// <summary> ������λ�õ����ֵ </summary>
    FMax,
    /// <summary> �����������λ������Сλ�ò� </summary>
    FRange,
    /// <summary> ��ֱ��������ǰλ�� </summary>
    FPosition: Integer;

    /// <summary> ������ƶ���Χ��ʵ�ʷ�Χ�ı��� </summary>
    FPercent: Single;

    /// <summary> �����ť���ƶ��Ĵ�С </summary>
    FBtnStep: Integer;

    /// <summary> ҳ���С </summary>
    FPageSize: Integer;

    /// <summary> ��ˮƽ���Ǵ�ֱ������ </summary>
    FOrientation: TOrientation;

    FMousePt: TPoint;

    /// <summary> �����¼� </summary>
    FOnScroll: TScrollEvent;

    FMouseDownControl: TBarControl;

    /// <summary> �������� </summary>
    FThumRect: TRect;

    /// <summary>
    /// ˮƽ��������Ӧ��ť����ֱ��������Ӧ�ϰ�ť
    /// </summary>
    FLeftBtnRect: TRect;

    /// <summary>
    /// ˮƽ��������Ӧ�Ұ�ť����ֱ��������Ӧ�°�ť
    /// </summary>
    FRightBtnRect: TRect;

    FOnVisibleChanged: TNotifyEvent;

    /// <summary>
    /// �õ������ȥҪʵ�ָı������
    /// </summary>
    procedure ReCalcButtonRect;

    /// <summary>
    /// ���㻬������
    /// </summary>
    procedure ReCalcThumRect;

    /// <summary>
    /// ���ù��������ͣ���ֱ��������ˮƽ��������
    /// </summary>
    /// <param name="Value">����������</param>
    procedure SetOrientation(Value: TOrientation);

    /// <summary>
    /// ���ù���������Сֵ
    /// </summary>
    /// <param name="Value">��Сֵ</param>
    procedure SetMin(const Value: Integer);

    /// <summary>
    /// ���ù����������ֵ
    /// </summary>
    /// <param name="Value">���ֵ</param>
    procedure SetMax(const Value: Integer);

    /// <summary>
    /// ���ù������ĳ�ʼλ��
    /// </summary>
    /// <param name="Value">��ʼλ��</param>
    procedure SetPosition(Value: Integer);

    /// <summary>
    /// ���ù�������ʾ��ҳ���С�����Max - Min��
    /// </summary>
    /// <param name="Value">ҳ���С</param>
    procedure SetPageSize(const Value :Integer);

    /// <summary>
    /// �����������ťҳ���ƶ���Χ
    /// </summary>
    /// <param name="Value">�ƶ���Χ</param>
    procedure SetBtnStep(const Value: Integer);

    procedure UpdateRangRect;
  protected
    procedure Resize; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure ScrollStep(ScrollCode: TScrollCode);
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure DoDrawThumBefor(const ACanvas: TCanvas; const AThumRect: TRect); virtual;

    property Percent: Single read FPercent write FPercent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintToEx(const ACanvas: TCanvas);
    property Max: Integer read FMax write SetMax;
    property Min: Integer read FMin write SetMin;
    property Rang: Integer read FRange;
    property PageSize: Integer read FPageSize write SetPageSize;
    property BtnStep: Integer read FBtnStep write SetBtnStep;
    property Position: Integer read FPosition write SetPosition;
    property Orientation: TOrientation read FOrientation write SetOrientation default oriHorizontal;
    property OnScroll: TScrollEvent read FOnScroll write FOnScroll;
    property OnVisibleChanged: TNotifyEvent read FOnVisibleChanged write FOnVisibleChanged;
  end;

implementation

uses
  Math;

const
  LineColor = clMedGray;
  IconWidth = 16;
  TitleBackColor = $B3ABAA;
  ThumBackColor = $D5D1D0;

{ THCScrollBar }

constructor THCScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMin := 0;
  FMax := 100;
  FRange := 100;
  FPageSize := 0;
  FBtnStep := 5;
  //
  Width := 20;
  Height := 20;
  Cursor := crArrow;  // crDefaultΪʲô���У�
end;

destructor THCScrollBar.Destroy;
begin

  inherited;
end;

procedure THCScrollBar.DoDrawThumBefor(const ACanvas: TCanvas;
  const AThumRect: TRect);
begin
end;

procedure THCScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FMousePt.X := X;
  FMousePt.Y := Y;
  if PtInRect(FLeftBtnRect, FMousePt) then  // �ж�����Ƿ��ڹ�������/��ť����
  begin
    FMouseDownControl := cbcLeftBtn;  // ���������������
    ScrollStep(scLineUp);  // �������ϣ��󣩹���
  end
  else
  if PtInRect(FThumRect, FMousePt) then  // ����ڻ�������
  begin
    FMouseDownControl := cbcThum;
  end
  else
  if PtInRect(FRightBtnRect, FMousePt) then  // �������/������
  begin
    FMouseDownControl := cbcRightBtn;
    ScrollStep(scLineDown);  // �������£��ң�����
  end
  else  // ����ڹ���������������
  begin
    FMouseDownControl := cbcBar;  // ������������������
    if (FThumRect.Top > Y) or (FThumRect.Left > X) then
      ScrollStep(scPageUp)  // �������ϣ��󣩷�ҳ
    else
    if (FThumRect.Bottom < Y) or (FThumRect.Right < X) then
      ScrollStep(scPageDown);  // �������£��ң���ҳ
  end;
end;

procedure THCScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vOffs: Integer;
begin
  inherited;
  if ssLeft in Shift then  // �϶�
  begin
    if FOrientation = oriHorizontal then  // ˮƽ
    begin
      if FMouseDownControl = cbcThum then  // �����ˮƽ��������������
      begin
        vOffs := X - FMousePt.X;
        Position := FPosition + Round(vOffs / FPercent);;
        FMousePt.X := X;  // ��ˮƽ���긳ֵ
      end;
    end
    else  // ��ֱ
    begin
      if FMouseDownControl = cbcThum then  // �ڻ������϶�
      begin
        vOffs := Y - FMousePt.Y;  // �Ͽ���������ʱ�����¿����϶������ǻᴥ�������¼��������˸����ν����word�������϶��鸽���ķ�Χ
        Position := FPosition + Round(vOffs / FPercent);
        FMousePt.Y := Y;  // �Դ�ֱ���긳��ǰYֵ
      end;
    end;
  end;
end;

procedure THCScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
end;

procedure THCScrollBar.Paint;
begin
  PaintToEx(Canvas);
end;

procedure THCScrollBar.PaintToEx(const ACanvas: TCanvas);
var
  vRect: TRect;
begin
  ACanvas.Brush.Color := TitleBackColor;
  ACanvas.FillRect(Bounds(0, 0, Width, Height));
  case FOrientation of
    oriHorizontal:  // ˮƽ������
      begin
        // ��ť
        ACanvas.Pen.Color := clWhite;
        vRect.Left := FLeftBtnRect.Left + ((FLeftBtnRect.Right - FLeftBtnRect.Left) - 4) div 2 + 4;
        vRect.Top := FLeftBtnRect.Top + ((FLeftBtnRect.Bottom - FLeftBtnRect.Top) - 7) div 2;
        ACanvas.MoveTo(vRect.Left, vRect.Top);
        ACanvas.LineTo(vRect.Left, vRect.Top + 7);
        ACanvas.MoveTo(vRect.Left - 1, vRect.Top + 1);
        ACanvas.LineTo(vRect.Left - 1, vRect.Top + 6);
        ACanvas.MoveTo(vRect.Left - 2, vRect.Top + 2);
        ACanvas.LineTo(vRect.Left - 2, vRect.Top + 5);
        ACanvas.MoveTo(vRect.Left - 3, vRect.Top + 3);
        ACanvas.LineTo(vRect.Left - 3, vRect.Top + 4);

        // �Ұ�ť
        vRect.Left := FRightBtnRect.Left + ((FRightBtnRect.Right - FRightBtnRect.Left) - 4) div 2;
        vRect.Top := FRightBtnRect.Top + ((FRightBtnRect.Bottom - FRightBtnRect.Top) - 7) div 2;
        ACanvas.MoveTo(vRect.Left, vRect.Top);
        ACanvas.LineTo(vRect.Left, vRect.Top + 7);
        ACanvas.MoveTo(vRect.Left + 1, vRect.Top + 1);
        ACanvas.LineTo(vRect.Left + 1, vRect.Top + 6);
        ACanvas.MoveTo(vRect.Left + 2, vRect.Top + 2);
        ACanvas.LineTo(vRect.Left + 2, vRect.Top + 5);
        ACanvas.MoveTo(vRect.Left + 3, vRect.Top + 3);
        ACanvas.LineTo(vRect.Left + 3, vRect.Top + 4);

        // ˮƽ����
        vRect := FThumRect;
        InflateRect(vRect, 0, -1);

        DoDrawThumBefor(ACanvas, vRect);

        ACanvas.Brush.Color := ThumBackColor;
        ACanvas.Pen.Color := LineColor;
        ACanvas.Rectangle(vRect);
        // �����ϵ�����
        vRect.Left := vRect.Left + (vRect.Right - vRect.Left) div 2;
        ACanvas.MoveTo(vRect.Left, 5);
        ACanvas.LineTo(vRect.Left, Height - 5);
        ACanvas.MoveTo(vRect.Left + 3, 5);
        ACanvas.LineTo(vRect.Left + 3, Height - 5);
        ACanvas.MoveTo(vRect.Left - 3, 5);
        ACanvas.LineTo(vRect.Left - 3, Height - 5);
      end;

    oriVertical:  // ��ֱ������
      begin
        // �ϰ�ť
        ACanvas.Pen.Color := clWhite;
        vRect.Left := FLeftBtnRect.Left + ((FLeftBtnRect.Right - FLeftBtnRect.Left) - 7) div 2;
        vRect.Top := FLeftBtnRect.Top + ((FLeftBtnRect.Bottom - FLeftBtnRect.Top) - 4) div 2 + 4;
        ACanvas.MoveTo(vRect.Left, vRect.Top);
        ACanvas.LineTo(vRect.Left + 7, vRect.Top);
        ACanvas.MoveTo(vRect.Left + 1, vRect.Top - 1);
        ACanvas.LineTo(vRect.Left + 6, vRect.Top - 1);
        ACanvas.MoveTo(vRect.Left + 2, vRect.Top - 2);
        ACanvas.LineTo(vRect.Left + 5, vRect.Top - 2);
        ACanvas.MoveTo(vRect.Left + 3, vRect.Top - 3);
        ACanvas.LineTo(vRect.Left + 4, vRect.Top - 3);

        // �°�ť
        vRect.Left := FRightBtnRect.Left + ((FRightBtnRect.Right - FRightBtnRect.Left) - 7) div 2;
        vRect.Top := FRightBtnRect.Top + ((FRightBtnRect.Bottom - FRightBtnRect.Top) - 4) div 2;
        ACanvas.MoveTo(vRect.Left, vRect.Top);
        ACanvas.LineTo(vRect.Left + 7, vRect.Top);
        ACanvas.MoveTo(vRect.Left + 1, vRect.Top + 1);
        ACanvas.LineTo(vRect.Left + 6, vRect.Top + 1);
        ACanvas.MoveTo(vRect.Left + 2, vRect.Top + 2);
        ACanvas.LineTo(vRect.Left + 5, vRect.Top + 2);
        ACanvas.MoveTo(vRect.Left + 3, vRect.Top + 3);
        ACanvas.LineTo(vRect.Left + 4, vRect.Top + 3);

        // ����
        vRect := FThumRect;
        InflateRect(vRect, -1, 0);

        DoDrawThumBefor(ACanvas, vRect);

        ACanvas.Brush.Color := ThumBackColor;
        ACanvas.Pen.Color := LineColor;
        ACanvas.Rectangle(vRect);
        // �����ϵ�����
        vRect.Top := vRect.Top + (vRect.Bottom - vRect.Top) div 2;
        ACanvas.MoveTo(5, vRect.Top);
        ACanvas.LineTo(Width - 5, vRect.Top);
        ACanvas.MoveTo(5, vRect.Top - 3);
        ACanvas.LineTo(Width - 5, vRect.Top - 3);
        ACanvas.MoveTo(5, vRect.Top + 3);
        ACanvas.LineTo(Width - 5, vRect.Top + 3);
      end;
  end;
end;

procedure THCScrollBar.ReCalcButtonRect;
begin
  case FOrientation of
    oriHorizontal:
      begin
        FLeftBtnRect := Rect(0, 0, ButtonSize, Height);
        FRightBtnRect := Rect(Width - ButtonSize, 0, Width, Height);
      end;
    oriVertical:
      begin
        FLeftBtnRect := Rect(0, 0, Width, ButtonSize);
        FRightBtnRect := Rect(0, Height - ButtonSize, Width, Height);
      end;
  end;
end;

procedure THCScrollBar.ReCalcThumRect;
var
  vPer: Single;
  vThumHeight: Integer;
begin
  case FOrientation of
    oriHorizontal:
      begin
        FThumRect.Top := 0;
        FThumRect.Bottom := Height;
        if FPageSize < FRange then  // ҳ��С�ڷ�Χ
        begin
          vPer := FPageSize / FRange;  // ���㻬�����
          // ���㻬��ĸ߶�
          vThumHeight := Round((Width - 2 * ButtonSize) * vPer);
          if vThumHeight < ButtonSize then  // ����߲���С��Ĭ����С�߶�
            vThumHeight := ButtonSize;

          FPercent := (Width - 2 * ButtonSize - vThumHeight) / (FRange - FPageSize);  // ����ɹ�����Χ��ʵ�ʴ���Χ�ı���
          if FPercent < 0 then Exit;  // ��ֹvThumHeightС��Leftbtn��RightBtn��ThumBtnĬ�ϸ߶��ܺ� 3 * ButtonSizeʱ�������
          if FPercent = 0 then
            FPercent := 1;

          FThumRect.Left := ButtonSize + Round(FPosition * FPercent);
          FThumRect.Right := FThumRect.Left + vThumHeight;
        end
        else  // ����������ڵ��ڷ�Χ
        begin
          FThumRect.Left := ButtonSize;
          FThumRect.Right := Width - ButtonSize;
        end;
      end;
    oriVertical:
      begin
        FThumRect.Left := 0;
        FThumRect.Right := Width;
        if FPageSize < FRange then  // ҳ��С�ڷ�Χ
        begin
          vPer := FPageSize / FRange;  // ���㻬�����
          // ���㻬��ĸ߶�
          vThumHeight := Round((Height - 2 * ButtonSize) * vPer);
          if vThumHeight < ButtonSize then  // ����߲���С��Ĭ����С�߶�
            vThumHeight := ButtonSize;

          FPercent := (Height - 2 * ButtonSize - vThumHeight) / (FRange - FPageSize);  // ����ɹ�����Χ��ʵ�ʴ���Χ�ı���
          if FPercent < 0 then Exit;  // ��ֹvThumHeightС��Leftbtn��RightBtn��ThumBtnĬ�ϸ߶��ܺ� 3 * ButtonSizeʱ�������
          if FPercent = 0 then
            FPercent := 1;

          FThumRect.Top := ButtonSize + Round(FPosition * FPercent);
          FThumRect.Bottom := FThumRect.Top + vThumHeight;
          //Scroll(scTrack, FPosition);  //����ƶ��ı们��Ĵ�ֱλ��
        end
        else  // ����������ڵ��ڷ�Χ
        begin
          FThumRect.Top := ButtonSize;
          FThumRect.Bottom := Height - ButtonSize;
        end;
      end;
  end;
end;

procedure THCScrollBar.Resize;
begin
  inherited Resize;
end;

procedure THCScrollBar.ScrollStep(ScrollCode: TScrollCode);
var
  vPos: Integer;
begin
  case ScrollCode of
    scLineUp:  // ����ϣ��󣩰�ť
      begin
        vPos := FPosition - FBtnStep;
        if vPos < FMin then  // �����ϣ���Խ��
          vPos := FMin;
        if FPosition <> vPos then
        begin
          Position := vPos;
          //Scroll(scLineUp, FPosition);
        end;
      end;
    scLineDown:
      begin
        vPos := FPosition + FBtnStep;
        if vPos > FRange - FPageSize then  // �����£��ң�Խ��
          vPos := FRange - FPageSize;
        if FPosition <> vPos then
        begin
          Position := vPos;
          //Scroll(scLineDown, FPosition);
        end;
      end;
    scPageUp:
      begin
        vPos := FPosition - FPageSize;
        {if FKind = sbVertical then
          vPos := Position - Height
        else
          vPos := Position - Width;}
        if vPos < FMin then
          vPos := FMin;
        if FPosition <> vPos then
        begin
          Position := vPos;
          //Scroll(scPageUp, FPosition);
        end;
      end;
    scPageDown:
      begin
        vPos := FPosition + FPageSize;
        {if FKind = sbVertical then
          vPos := Position + Height
        else
          vPos := Position + Width;}
        if vPos > FRange - FPageSize then
          vPos := FRange - FPageSize;
        if FPosition <> vPos then
        begin
          Position := vPos;
          //Scroll(scPageDown, FPosition);
        end;
      end;
    scPosition: ;
    scTrack: ;
    scTop: ;
    scBottom: ;
    scEndScroll: ;
  end;
end;

procedure THCScrollBar.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  if FOrientation = oriVertical then
    Self.FPageSize := Height
  else
    Self.FPageSize := Width;

  if FPosition + FPageSize > FMax then  // ��С�仯����Ҫ����ȷ��Position
    FPosition := Math.Max(FMax - FPageSize, FMin);

  ReCalcThumRect;  // ���¼��㻬������
  ReCalcButtonRect;  // ���¼��㰴ť����
end;

procedure THCScrollBar.SetBtnStep(const Value: Integer);
begin
  if FBtnStep <> Value then
    FBtnStep := Value;
end;

procedure THCScrollBar.SetMax(const Value: Integer);
begin
  if FMax <> Value then
  begin
    if Value < FMin then
      FMax := FMin
    else
      FMax := Value;

    if FPosition + FPageSize > FMax then
      FPosition := Math.Max(FMax - FPageSize, FMin);

    FRange := FMax - FMin;
    ReCalcThumRect;  // ��������
    UpdateRangRect;  // �ػ�
  end;
end;

procedure THCScrollBar.SetMin(const Value: Integer);
begin
  if FMin <> Value then
  begin
    if Value > FMax then
      FMin := FMax
    else
      FMin := Value;
    if FPosition < FMin then
      FPosition := FMin;
    FRange := FMax - FMin;
    ReCalcThumRect;  // ��������
    UpdateRangRect;  // �ػ�
  end;
end;

procedure THCScrollBar.SetOrientation(Value: TOrientation);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    if Value = oriHorizontal then  // ����Ϊˮƽ������
    begin
      Height := 20;  // ��ֵˮƽ�������ĸ߶�Ϊ 20
    end
    else
    if Value = oriVertical then  // ��ֱ������
    begin
      Width := 20;
    end;
    ReCalcButtonRect;
    ReCalcThumRect;
    UpdateRangRect;  // �ػ�
  end;
end;

procedure THCScrollBar.SetPageSize(const Value: Integer);
begin
  if FPageSize <> Value then
  begin
    FPageSize := Value;
    //ReCalcButtonRect;
    ReCalcThumRect;  // ���¼�����Ա��ʣ����Max - Min��
    UpdateRangRect;  // �ػ�
  end;
end;

procedure THCScrollBar.SetPosition(Value: Integer);
var
  vPos: Integer;
begin
  if Value < FMin then
    vPos := FMin
  else
  if Value + FPageSize > FMax then
    vPos := Math.Max(FMax - FPageSize, FMin)
  else
    vPos := Value;

  if FPosition <> vPos then
  begin
    FPosition := vPos;
    ReCalcThumRect;  // ��������
    //Repaint;
    UpdateRangRect;  // �ػ�

    if Assigned(FOnScroll) then  // ����
      FOnScroll(Self, scPosition, FPosition);
  end;
end;

procedure THCScrollBar.UpdateRangRect;
var
  vRect: TRect;
begin
  //if HandleAllocated then
  if Assigned(Parent) and Parent.HandleAllocated then
  begin
    vRect := ClientRect;
    OffsetRect(vRect, Left, Top);
    InvalidateRect(Parent.Handle, vRect, False);
    UpdateWindow(Parent.Handle);
    //RedrawWindow(Handle, nil, 0, RDW_INVALIDATE);
  end;
end;

end.
