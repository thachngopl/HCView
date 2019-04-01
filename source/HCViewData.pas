{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{            ֧���������ĵ��������Ԫ               }
{                                                       }
{*******************************************************}

unit HCViewData;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, Generics.Collections, HCCustomData,
  HCRichData, HCItem, HCStyle, HCParaStyle, HCTextStyle, HCTextItem, HCRectItem,
  HCCommon, HCViewDevData, HCList;

type
  THCDomainInfo = class(TObject)
  strict private
    FBeginNo, FEndNo: Integer;
  public
    constructor Create;
    procedure Clear;
    /// <summary> �����Ƿ������Item(ͷ��βҲ��) </summary>
    function Contain(const AItemNo: Integer): Boolean;
    property BeginNo: Integer read FBeginNo write FBeginNo;
    property EndNo: Integer read FEndNo write FEndNo;
  end;

  TStyleItemEvent = function (const AData: THCCustomData; const AStyleNo: Integer): THCCustomItem of object;
  TOnCanEditEvent = function(const Sender: TObject): Boolean of object;
  TDrawItemPaintContentEvent = procedure(const AData: THCCustomData;
    const ADrawItemNo: Integer; const ADrawRect, AClearRect: TRect; const ADrawText: string;
    const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
    const ACanvas: TCanvas; const APaintInfo: TPaintInfo) of object;

  THCViewData = class(THCViewDevData)  // ���ı������࣬����Ϊ������ʾ���ı���Ļ���
  private
    FDomainStartDeletes: THCIntegerList;  // ������ѡ��ɾ��ʱ��������ʼ������ѡ��ʱ��ɾ���˽����������ʼ�Ŀ�ɾ��
    FHotDomain,  // ��ǰ������
    FActiveDomain  // ��ǰ������
      : THCDomainInfo;

    FHotDomainRGN, FActiveDomainRGN: HRGN;
    FDrawActiveDomainRegion, FDrawHotDomainRegion: Boolean;  // �Ƿ������߿�
    FOnCreateItemByStyle: TStyleItemEvent;
    FOnCanEdit: TOnCanEditEvent;
    FOnDrawItemPaintContent: TDrawItemPaintContentEvent;

    procedure GetDomainFrom(const AItemNo, AOffset: Integer; const ADomainInfo: THCDomainInfo);
  protected
    function CreateItemByStyle(const AStyleNo: Integer): THCCustomItem; override;
    function CanDeleteItem(const AItemNo: Integer): Boolean; override;

    /// <summary> ���ڴ���������Items�󣬼�鲻�ϸ��Item��ɾ�� </summary>
    function CheckInsertItemCount(const AStartNo, AEndNo: Integer): Integer; override;

    procedure DoDrawItemPaintBefor(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure DoDrawItemPaintContent(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect, AClearRect: TRect; const ADrawText: string;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure DoDrawItemPaintAfter(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
  public
    constructor Create(const AStyle: THCStyle); override;
    destructor Destroy; override;

    procedure PaintData(const ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom, AVOffset, AFristDItemNo, ALastDItemNo: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure InitializeField; override;
    procedure GetCaretInfo(const AItemNo, AOffset: Integer; var ACaretInfo: THCCaretInfo); override;
    function DeleteSelected: Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function InsertItem(const AItem: THCCustomItem): Boolean; override;
    function InsertItem(const AIndex: Integer; const AItem: THCCustomItem;
      const AOffsetBefor: Boolean = True): Boolean; override;
    function CanEdit: Boolean; override;

    /// <summary> ���ݴ������"ģ��"������ </summary>
    /// <param name="AMouldDomain">"ģ��"������˷������������ͷ�</param>
    function InsertDomain(const AMouldDomain: THCDomainItem): Boolean;

    /// <summary> ����ѡ�з�Χ </summary>
    /// <param name="ASilence">�Ƿ�"��Ĭ"���ã�False����Ӧ��ѡ�в�������ض���(���λ�á��������) True������Ӧ(�ⲿ�Լ�����)</param>
    procedure SetSelectBound(const AStartNo, AStartOffset, AEndNo, AEndOffset: Integer;
      const ASilence: Boolean = True);

    /// <summary> ���ѡ��ָ��Item������� </summary>
    procedure SelectItemAfterWithCaret(const AItemNo: Integer);

    /// <summary> ���ѡ�����һ��Item������� </summary>
    procedure SelectLastItemAfterWithCaret;

    /// <summary> ���ѡ����һ��Item����ǰ�� </summary>
    procedure SelectFirstItemBeforWithCaret;

    /// <summary> ��ȡDomainItem��Ե���һ��ItemNo </summary>
    /// <param name="AItemNo">��ǰDomainItem(ͷ��β)</param>
    function GetDomainAnother(const AItemNo: Integer): Integer;

    /// <summary> ��ǰλ�ÿ�ʼ����ָ�������� </summary>
    /// <param name="AKeyword">Ҫ���ҵĹؼ���</param>
    /// <param name="AForward">True����ǰ��False�����</param>
    /// <param name="AMatchCase">True�����ִ�Сд��False�������ִ�Сд</param>
    /// <returns>True���ҵ�</returns>
    function Search(const AKeyword: string; const AForward, AMatchCase: Boolean): Boolean;
    function Replace(const AText: string): Boolean;

    procedure GetCaretInfoCur(var ACaretInfo: THCCaretInfo);
    procedure TraverseItem(const ATraverse: TItemTraverse);

    property HotDomain: THCDomainInfo read FHotDomain;
    property ActiveDomain: THCDomainInfo read FActiveDomain;
    property OnCreateItemByStyle: TStyleItemEvent read FOnCreateItemByStyle write FOnCreateItemByStyle;
    property OnCanEdit: TOnCanEditEvent read FOnCanEdit write FOnCanEdit;
    property OnDrawItemPaintContent: TDrawItemPaintContentEvent read FOnDrawItemPaintContent write FOnDrawItemPaintContent;
  end;

implementation

uses
  StrUtils;

{ THCViewData }

function THCViewData.CanDeleteItem(const AItemNo: Integer): Boolean;
var
  vItemNo: Integer;
begin
  Result := inherited CanDeleteItem(AItemNo);
  if Result then
  begin
    if Items[AItemNo].StyleNo = THCStyle.Domain then  // �����ʶ
    begin
      if (Items[AItemNo] as THCDomainItem).MarkType = TMarkType.cmtEnd then  // �������ʶ
      begin
        vItemNo := GetDomainAnother(AItemNo);  // ����ʼ
        Result := (vItemNo >= SelectInfo.StartItemNo) and (vItemNo <= SelectInfo.EndItemNo);
        if Result then  // ��ʼҲ��ѡ��ɾ����Χ��
          FDomainStartDeletes.Add(vItemNo);  // ��¼����
      end
      else  // ����ʼ���
        Result := FDomainStartDeletes.IndexOf(AItemNo) >= 0;  // ������ʶ�Ѿ������Ϊ��ɾ��
    end;
  end;
end;

function THCViewData.CanEdit: Boolean;
begin
  Result := inherited CanEdit;
  if Result and Assigned(FOnCanEdit) then
    Result := FOnCanEdit(Self);
end;

function THCViewData.CheckInsertItemCount(const AStartNo,
  AEndNo: Integer): Integer;
var
  i, vDelCount: Integer;
begin
  Result := inherited CheckInsertItemCount(AStartNo, AEndNo);

  // �����ػ�ճ���ȴ�������Items��ƥ�������ʼ������ʶ��ɾ��
  vDelCount := 0;
  for i := AStartNo to AEndNo do  // ��ǰ������û�в�����ʼ��ʶ����ɾ���������������ʶ
  begin
    if Items[i] is THCDomainItem then  // ���ʶ
    begin
      if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtEnd then  // �ǽ�����˵��û�в����Ӧ����ʼ
      begin
        if i < AEndNo then  // ������󣬺���̳������ʼ����
          Items[i + 1].ParaFirst := Items[i].ParaFirst;

        Items.Delete(i);
        Inc(vDelCount);

        if (i > AStartNo) and (i <= AEndNo - vDelCount) then  // ɾ�����м��
        begin
          if (not Items[i - 1].ParaFirst)
            and (not Items[i].ParaFirst)
            and MergeItemText(Items[i - 1], Items[i])  // ǰ�󶼲��Ƕ��ף����ܺϲ�
          then
          begin
            Items.Delete(i);
            Inc(vDelCount);
          end;
        end;

        Break;
      end
      else  // ����ʼ���ǣ����õ�����
        Break;
    end;
  end;

  for i := AEndNo - vDelCount downto AStartNo do  // �Ӻ���ǰ����û�в��������ʶ����
  begin
    if Items[i] is THCDomainItem then  // ���ʶ
    begin
      if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ����ʼ��˵��û�в����Ӧ�Ľ���
      begin
        if i < AEndNo - vDelCount then  // ������󣬺���̳������ʼ����
          Items[i + 1].ParaFirst := Items[i].ParaFirst;

        Items.Delete(i);
        Inc(vDelCount);

        if (i > AStartNo) and (i <= AEndNo - vDelCount) then  // ɾ�����м��
        begin
          if (not Items[i - 1].ParaFirst)
            and (not Items[i].ParaFirst)
            and MergeItemText(Items[i - 1], Items[i])  // ǰ�󶼲��Ƕ��ף����ܺϲ�
          then
          begin
            Items.Delete(i);
            Inc(vDelCount);
          end;
        end;

        Break;
      end
      else  // �ǽ������ǣ����õ�����
        Break;
    end;
  end;

  Result := Result - vDelCount;
end;

constructor THCViewData.Create(const AStyle: THCStyle);
begin
  FDomainStartDeletes := THCIntegerList.Create;
  FHotDomain := THCDomainInfo.Create;
  FActiveDomain := THCDomainInfo.Create;
  inherited Create(AStyle);
end;

function THCViewData.CreateItemByStyle(const AStyleNo: Integer): THCCustomItem;
begin
  Result := nil;

  if Assigned(FOnCreateItemByStyle) then  // �Զ���������ڴ˴�����
    Result := FOnCreateItemByStyle(Self, AStyleNo);

  if not Assigned(Result) then
    Result := inherited CreateItemByStyle(AStyleNo);
end;

function THCViewData.DeleteSelected: Boolean;
begin
  FDomainStartDeletes.Clear;  // �����ɾ��ʱ��¼ǰ�������Ϣ
  Result := inherited DeleteSelected;
end;

destructor THCViewData.Destroy;
begin
  FHotDomain.Free;
  FActiveDomain.Free;
  FDomainStartDeletes.Free;
  inherited Destroy;
end;

procedure THCViewData.DoDrawItemPaintAfter(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);

  {$REGION ' DrawLineLastMrak ��β�Ļ��з� '}
  procedure DrawLineLastMrak(const ADrawRect: TRect);
  var
    vPt: TPoint;
  begin
    ACanvas.Pen.Width := 1;
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Color := clActiveBorder;

    if APaintInfo.ScaleX <> 1 then
    begin
      SetViewportExtEx(ACanvas.Handle, APaintInfo.WindowWidth, APaintInfo.WindowHeight, @vPt);
      try
        ACanvas.MoveTo(APaintInfo.GetScaleX(ADrawRect.Right) + 4, APaintInfo.GetScaleY(ADrawRect.Bottom) - 8);
        ACanvas.LineTo(APaintInfo.GetScaleX(ADrawRect.Right) + 6, APaintInfo.GetScaleY(ADrawRect.Bottom) - 8);
        ACanvas.LineTo(APaintInfo.GetScaleX(ADrawRect.Right) + 6, APaintInfo.GetScaleY(ADrawRect.Bottom) - 3);

        ACanvas.MoveTo(APaintInfo.GetScaleX(ADrawRect.Right),     APaintInfo.GetScaleY(ADrawRect.Bottom) - 3);
        ACanvas.LineTo(APaintInfo.GetScaleX(ADrawRect.Right) + 6, APaintInfo.GetScaleY(ADrawRect.Bottom) - 3);

        ACanvas.MoveTo(APaintInfo.GetScaleX(ADrawRect.Right) + 1, APaintInfo.GetScaleY(ADrawRect.Bottom) - 4);
        ACanvas.LineTo(APaintInfo.GetScaleX(ADrawRect.Right) + 1, APaintInfo.GetScaleY(ADrawRect.Bottom) - 1);

        ACanvas.MoveTo(APaintInfo.GetScaleX(ADrawRect.Right) + 2, APaintInfo.GetScaleY(ADrawRect.Bottom) - 5);
        ACanvas.LineTo(APaintInfo.GetScaleX(ADrawRect.Right) + 2, APaintInfo.GetScaleY(ADrawRect.Bottom));
      finally
        SetViewportExtEx(ACanvas.Handle, APaintInfo.GetScaleX(APaintInfo.WindowWidth),
          APaintInfo.GetScaleY(APaintInfo.WindowHeight), @vPt);
      end;
    end
    else
    begin
      ACanvas.MoveTo(ADrawRect.Right + 4, ADrawRect.Bottom - 8);
      ACanvas.LineTo(ADrawRect.Right + 6, ADrawRect.Bottom - 8);
      ACanvas.LineTo(ADrawRect.Right + 6, ADrawRect.Bottom - 3);

      ACanvas.MoveTo(ADrawRect.Right,     ADrawRect.Bottom - 3);
      ACanvas.LineTo(ADrawRect.Right + 6, ADrawRect.Bottom - 3);

      ACanvas.MoveTo(ADrawRect.Right + 1, ADrawRect.Bottom - 4);
      ACanvas.LineTo(ADrawRect.Right + 1, ADrawRect.Bottom - 1);

      ACanvas.MoveTo(ADrawRect.Right + 2, ADrawRect.Bottom - 5);
      ACanvas.LineTo(ADrawRect.Right + 2, ADrawRect.Bottom);
    end;
  end;
  {$ENDREGION}

begin
  inherited DoDrawItemPaintAfter(AData, ADrawItemNo, ADrawRect, ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);

  if not APaintInfo.Print then
  begin
    if AData.Style.ShowParaLastMark then  // ��ʾ��β�Ļ��з�
    begin
      if (ADrawItemNo < DrawItems.Count - 1) and DrawItems[ADrawItemNo + 1].ParaFirst then
        DrawLineLastMrak(ADrawRect)  // ��β�Ļ��з�
      else
      if ADrawItemNo = DrawItems.Count - 1 then
        DrawLineLastMrak(ADrawRect);  // ��β�Ļ��з�
    end;
  end;
end;

procedure THCViewData.DoDrawItemPaintBefor(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vDrawHotDomainBorde, vDrawActiveDomainBorde: Boolean;
  vItemNo: Integer;
  vDliRGN: HRGN;
begin
  inherited DoDrawItemPaintBefor(AData, ADrawItemNo, ADrawRect, ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);

  if not APaintInfo.Print then  // ƴ����Χ
  begin
    vDrawHotDomainBorde := False;
    vDrawActiveDomainBorde := False;
    vItemNo := DrawItems[ADrawItemNo].ItemNo;

    if FHotDomain.BeginNo >= 0 then  // ��Hot��
      vDrawHotDomainBorde := FHotDomain.Contain(vItemNo);

    if FActiveDomain.BeginNo >= 0 then  // �м�����
      vDrawActiveDomainBorde := FActiveDomain.Contain(vItemNo);

    if vDrawHotDomainBorde or vDrawActiveDomainBorde then  // ��Hot��򼤻�����
    begin
      vDliRGN := CreateRectRgn(ADrawRect.Left, ADrawRect.Top, ADrawRect.Right, ADrawRect.Bottom);
      try
        if (FHotDomain.BeginNo >= 0) and vDrawHotDomainBorde then
          CombineRgn(FHotDomainRGN, FHotDomainRGN, vDliRGN, RGN_OR);
        if (FActiveDomain.BeginNo >= 0) and vDrawActiveDomainBorde then
          CombineRgn(FActiveDomainRGN, FActiveDomainRGN, vDliRGN, RGN_OR);
      finally
        DeleteObject(vDliRGN);
      end;
    end;
  end;
end;

procedure THCViewData.DoDrawItemPaintContent(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect, AClearRect: TRect;
  const ADrawText: string; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
begin
  inherited DoDrawItemPaintContent(AData, ADrawItemNo, ADrawRect, AClearRect,
    ADrawText, ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom,
    ACanvas, APaintInfo);

  if Assigned(FOnDrawItemPaintContent) then
  begin
    FOnDrawItemPaintContent(AData, ADrawItemNo, ADrawRect, AClearRect, ADrawText,
      ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

function THCViewData.GetDomainAnother(const AItemNo: Integer): Integer;
var
  vDomainItem: THCDomainItem;
  i: Integer;
begin
  Result := -1;

  // ���ⲿ��֤AItemNo��Ӧ����THCDomainItem
  vDomainItem := Self.Items[AItemNo] as THCDomainItem;
  if vDomainItem.MarkType = TMarkType.cmtEnd then  // �ǽ�����ʶ
  begin
    for i := AItemNo - 1 downto 0 do  // ����ʼ��ʶ
    begin
      if Items[i].StyleNo = THCStyle.Domain then
      begin
        if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ����ʼ��ʶ
        begin
          if (Items[i] as THCDomainItem).Level = vDomainItem.Level then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
    end;
  end
  else  // ����ʼ��ʶ
  begin
    for i := AItemNo + 1 to Self.Items.Count - 1 do  // �ҽ�����ʶ
    begin
      if Items[i].StyleNo = THCStyle.Domain then
      begin
        if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtEnd then  // �ǽ�����ʶ
        begin
          if (Items[i] as THCDomainItem).Level = vDomainItem.Level then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure THCViewData.GetDomainFrom(const AItemNo, AOffset: Integer;
  const ADomainInfo: THCDomainInfo);
var
  i, vStartNo, vEndNo, vCount: Integer;
  vLevel: Byte;
begin
  ADomainInfo.Clear;

  if (AItemNo < 0) or (AOffset < 0) then Exit;

  { ����ʼ��ʶ }
  vStartNo := AItemNo;
  vEndNo := AItemNo;
  if Items[AItemNo]is THCDomainItem then  // ��ʼλ�þ���Group
  begin
    if (Items[AItemNo] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ��ʼλ������ʼ���
    begin
      if AOffset = OffsetAfter then  // ����ں���
      begin
        ADomainInfo.BeginNo := AItemNo;  // ��ǰ��Ϊ��ʼ��ʶ
        vEndNo := AItemNo + 1;
      end
      else  // �����ǰ��
      begin
        if AItemNo > 0 then  // ���ǵ�һ��
          vStartNo := AItemNo - 1  // ��ǰһ����ǰ
        else  // ���ڵ�һ��ǰ��
          Exit;  // ��������
      end;
    end
    else  // ����λ���ǽ������
    begin
      if AOffset = OffsetAfter then  // ����ں���
      begin
        if AItemNo < Items.Count - 1 then  // �������һ��
          vEndNo := AItemNo + 1
        else  // �����һ������
          Exit;  // ��������
      end
      else  // �����ǰ��
      begin
        ADomainInfo.EndNo := AItemNo;
        vStartNo := AItemNo - 1;
      end;
    end;
  end;

  if ADomainInfo.BeginNo < 0 then
  begin
    vCount := 0;

    if vStartNo < Self.Items.Count div 2 then  // ��ǰ���
    begin
      for i := vStartNo downto 0 do  // ����ǰ����ʼ
      begin
        if Items[i] is THCDomainItem then
        begin
          if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ��ʼ���
          begin
            if vCount > 0 then
              Dec(vCount)
            else
            begin
              ADomainInfo.BeginNo := i;
              vLevel := (Items[i] as THCDomainItem).Level;
              Break;
            end;
          end
          else  // �������
            Inc(vCount);  // ��Ƕ��
        end;
      end;

      if (ADomainInfo.BeginNo >= 0) and (ADomainInfo.EndNo < 0) then  // �ҽ�����ʶ
      begin
        for i := vEndNo to Items.Count - 1 do
        begin
          if Items[i] is THCDomainItem then
          begin
            if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtEnd then  // �ǽ�β
            begin
              if (Items[i] as THCDomainItem).Level = vLevel then
              begin
                ADomainInfo.EndNo := i;
                Break;
              end;
            end;
          end;
        end;

        if ADomainInfo.EndNo < 0 then
          raise Exception.Create('�쳣����ȡ�����λ�ó���');
      end;
    end
    else  // �ں���
    begin
      for i := vEndNo to Self.Items.Count - 1 do  // �������ҽ���
      begin
        if Items[i] is THCDomainItem then
        begin
          if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtEnd then  // �������
          begin
            if vCount > 0 then
              Dec(vCount)
            else
            begin
              ADomainInfo.EndNo := i;
              vLevel := (Items[i] as THCDomainItem).Level;
              Break;
            end;
          end
          else
            Inc(vCount);
        end;
      end;

      if (ADomainInfo.EndNo >= 0) and (ADomainInfo.BeginNo < 0) then  // ����ʼ��ʶ
      begin
        for i := vStartNo downto 0 do
        begin
          if Items[i] is THCDomainItem then
          begin
            if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ����ʼ
            begin
              if (Items[i] as THCDomainItem).Level = vLevel then
              begin
                ADomainInfo.BeginNo := i;
                Break;
              end;
            end;
          end;
        end;

        if ADomainInfo.BeginNo < 0 then
          raise Exception.Create('�쳣����ȡ����ʼλ�ó���');
      end;
    end;
  end;
end;

procedure THCViewData.GetCaretInfo(const AItemNo, AOffset: Integer;
  var ACaretInfo: THCCaretInfo);
var
  vTopData: THCRichData;
begin
  inherited GetCaretInfo(AItemNo, AOffset, ACaretInfo);

  // ��ֵ����Group��Ϣ������� MouseDown
  if Self.SelectInfo.StartItemNo >= 0 then
  begin
    vTopData := GetTopLevelData;
    if vTopData = Self then
    begin
      if FActiveDomain.BeginNo >= 0 then  // ԭ������Ϣ(����δͨ��������ƶ����ʱû�����)
      begin
        FActiveDomain.Clear;
        FDrawActiveDomainRegion := False;
        Style.UpdateInfoRePaint;
      end;

      GetDomainFrom(SelectInfo.StartItemNo, SelectInfo.StartItemOffset, FActiveDomain);  // ��ȡ��ǰ��괦ActiveDeGroup��Ϣ

      if FActiveDomain.BeginNo >= 0 then
      begin
        FDrawActiveDomainRegion := True;
        Style.UpdateInfoRePaint;
      end;
    end;
  end;
end;

procedure THCViewData.GetCaretInfoCur(var ACaretInfo: THCCaretInfo);
begin
  if Style.UpdateInfo.Draging then
    Self.GetCaretInfo(Self.MouseMoveItemNo, Self.MouseMoveItemOffset, ACaretInfo)
  else
    Self.GetCaretInfo(SelectInfo.StartItemNo, SelectInfo.StartItemOffset, ACaretInfo);
end;

function THCViewData.InsertItem(const AItem: THCCustomItem): Boolean;
begin
  Result := inherited InsertItem(AItem);
  if Result then
  begin
    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;
    Style.UpdateInfoReScroll;
  end;
end;

procedure THCViewData.InitializeField;
begin
  inherited InitializeField;
  FHotDomain.Clear;
  FActiveDomain.Clear;
end;

function THCViewData.InsertDomain(const AMouldDomain: THCDomainItem): Boolean;
var
  vDomainItem: THCDomainItem;
begin
  Result := False;
  if not CanEdit then Exit;

  Undo_GroupBegin(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
  try
    Self.BeginBatchInsert;
    try
      // ����ͷ
      vDomainItem := CreateDefaultDomainItem as THCDomainItem;
      if Assigned(AMouldDomain) then
        vDomainItem.Assign(AMouldDomain);
      vDomainItem.MarkType := cmtBeg;
      if FActiveDomain.BeginNo >= 0 then
        vDomainItem.Level := (Items[FActiveDomain.BeginNo] as THCDomainItem).Level + 1;

      Result := InsertItem(vDomainItem);

      if Result then  // ����β
      begin
        vDomainItem := CreateDefaultDomainItem as THCDomainItem;
        if Assigned(AMouldDomain) then
          vDomainItem.Assign(AMouldDomain);
        vDomainItem.MarkType := cmtEnd;
        if FActiveDomain.BeginNo >= 0 then
          vDomainItem.Level := (Items[FActiveDomain.BeginNo] as THCDomainItem).Level + 1;

        Result := InsertItem(vDomainItem);
      end;
    finally
      Self.EndBatchInsert;
    end;
  finally
    Undo_GroupEnd(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
  end;
end;

function THCViewData.InsertItem(const AIndex: Integer;
  const AItem: THCCustomItem; const AOffsetBefor: Boolean = True): Boolean;
begin
  Result := inherited InsertItem(AIndex, AItem, AOffsetBefor);
  if Result then
  begin
    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;
    Style.UpdateInfoReScroll;
  end;
end;

procedure THCViewData.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  // ��������Group��Ϣ����ֵ�� GetCaretInfo
  if FActiveDomain.BeginNo >= 0 then
    Style.UpdateInfoRePaint;
  FActiveDomain.Clear;
  FDrawActiveDomainRegion := False;

  inherited MouseDown(Button, Shift, X, Y);

  if Button = TMouseButton.mbRight then  // �Ҽ��˵�ʱ������ȡ��괦FActiveDomain
    Style.UpdateInfoReCaret;
end;

procedure THCViewData.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vTopData: THCViewData;
begin
  // ��� FHotDeGroup ��Ϣ
  if FHotDomain.BeginNo >= 0 then
    Style.UpdateInfoRePaint;
  FHotDomain.Clear;
  FDrawHotDomainRegion := False;

  inherited MouseMove(Shift, X, Y);

  if not Self.MouseMoveRestrain then  // ��Item��
  begin
    Self.GetDomainFrom(Self.MouseMoveItemNo, Self.MouseMoveItemOffset, FHotDomain);  // ȡHotDeGroup
    vTopData := Self.GetTopLevelDataAt(X, Y) as THCViewData;
    if (vTopData = Self) or (not vTopData.FDrawHotDomainRegion) then  // �������� �� ���㲻�����Ҷ���û��HotDeGroup  201711281352
    begin
      if FHotDomain.BeginNo >= 0 then  // ��FHotDeGroup
      begin
        FDrawHotDomainRegion := True;
        Style.UpdateInfoRePaint;
      end;
    end;
  end;
end;

procedure THCViewData.PaintData(const ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
  ADataScreenTop, ADataScreenBottom, AVOffset, AFristDItemNo, ALastDItemNo: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vOldColor: TColor;
begin
  if not APaintInfo.Print then  // �Ǵ�ӡ���Ƽ���������
  begin
    if FDrawHotDomainRegion then
      FHotDomainRGN := CreateRectRgn(0, 0, 0, 0);

    if FDrawActiveDomainRegion then
      FActiveDomainRGN := CreateRectRgn(0, 0, 0, 0);
  end;

  inherited PaintData(ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
    ADataScreenTop, ADataScreenBottom, AVOffset, AFristDItemNo, ALastDItemNo,
    ACanvas, APaintInfo);

  if not APaintInfo.Print then  // �Ǵ�ӡ���Ƽ���������
  begin
    vOldColor := ACanvas.Brush.Color;  // ��Ϊʹ��Brush���Ʊ߿�������Ҫ����ԭ��ɫ
    try
      if FDrawHotDomainRegion then
      begin
        ACanvas.Brush.Color := clActiveBorder;
        FrameRgn(ACanvas.Handle, FHotDomainRGN, ACanvas.Brush.Handle, 1, 1);
        DeleteObject(FHotDomainRGN);
      end;

      if FDrawActiveDomainRegion then
      begin
        ACanvas.Brush.Color := clBlue;
        FrameRgn(ACanvas.Handle, FActiveDomainRGN, ACanvas.Brush.Handle, 1, 1);
        DeleteObject(FActiveDomainRGN);
      end;
    finally
      ACanvas.Brush.Color := vOldColor;
    end;
  end;
end;

function THCViewData.Replace(const AText: string): Boolean;
begin
//  DeleteSelected;
  InsertText(AText);
end;

function THCViewData.Search(const AKeyword: string; const AForward,
  AMatchCase: Boolean): Boolean;
var
  vKeyword: string;

  {$REGION ' DoSearchByOffset '}
  function DoSearchByOffset(const AItemNo, AOffset: Integer): Boolean;

    function ReversePos(const SubStr, S: String): Integer;
    var
      i : Integer;
    begin
      Result := 0;

      i := Pos(ReverseString(SubStr), ReverseString(S));
      if i > 0 then
      begin
        i := Length(S) - i - Length(SubStr) + 2;
        Result := i;
      end;
    end;

  var
    vPos, vItemNo: Integer;
    vText, vConcatText, vOverText: string;
  begin
    Result := False;

    if Self.Items[AItemNo].StyleNo < THCStyle.Null then
    begin
      Result := (Self.Items[AItemNo] as THCCustomRectItem).Search(AKeyword, AForward, AMatchCase);
      if Result then
      begin
        Self.SelectInfo.StartItemNo := AItemNo;
        Self.SelectInfo.StartItemOffset := OffsetInner;
        Self.SelectInfo.EndItemNo := -1;
        Self.SelectInfo.EndItemOffset := -1;
      end;
    end
    else
    begin
      if AForward then  // ��ǰ��
      begin
        vText := (Self.Items[AItemNo] as THCTextItem).SubString(1, AOffset);
        if not AMatchCase then  // �����ִ�Сд
          vText := UpperCase(vText);

        vPos := ReversePos(vKeyword, vText);  // һ���ַ�������һ���ַ����������ֵ�λ��(��LastDelimiter�����ִ�Сд)
      end
      else  // �����
      begin
        vText := (Self.Items[AItemNo] as THCTextItem).SubString(AOffset + 1,
          Self.Items[AItemNo].Length - AOffset);
        if not AMatchCase then  // �����ִ�Сд
          vText := UpperCase(vText);

        vPos := Pos(vKeyword, vText);
      end;

      if vPos > 0 then  // ��ǰItem��ƥ��
      begin
        Self.SelectInfo.StartItemNo := AItemNo;

        if AForward then  // ��ǰ��
          Self.SelectInfo.StartItemOffset := vPos - 1
        else  // �����
          Self.SelectInfo.StartItemOffset := AOffset + vPos - 1;

        Self.SelectInfo.EndItemNo := AItemNo;
        Self.SelectInfo.EndItemOffset := Self.SelectInfo.StartItemOffset + Length(vKeyword);

        Result := True;
      end
      else  // û�ҵ�ƥ�䣬������ͬ�����ڵ�TextItem�ϲ������
      if (vText <> '') and (Length(vKeyword) > 1) then
      begin
        if AForward then  // ��ǰ����ͬ������
        begin
          vItemNo := AItemNo;
          vConcatText := vText;
          vOverText := '';

          while (vItemNo > 0)
            and (not Self.Items[vItemNo].ParaFirst)
            and (Self.Items[vItemNo - 1].StyleNo > THCStyle.Null)
          do
          begin
            vText := RightStr(Self.Items[vItemNo - 1].Text, Length(vKeyword) - 1);  // ȡ����ȹؼ�����һ���ַ����ȵģ��Ա�͵�ǰĩβ���һ��ƴ��
            vOverText := vOverText + vText;  // ��¼ƴ���˶��ٸ��ַ�
            vConcatText := vText + vConcatText;  // ƴ�Ӻ���ַ�
            if not AMatchCase then  // �����ִ�Сд
              vConcatText := UpperCase(vConcatText);

            vPos := Pos(vKeyword, vConcatText);
            if vPos > 0 then  // �ҵ���
            begin
              Self.SelectInfo.StartItemNo := vItemNo - 1;
              Self.SelectInfo.StartItemOffset := Self.Items[vItemNo - 1].Length - (Length(vText) - vPos) - 1;

              Self.SelectInfo.EndItemNo := AItemNo;
              Self.SelectInfo.EndItemOffset := vPos + Length(vKeyword) - 1  // �ؼ�������ַ���ƫ��λ��
                - Length(vText);  // ��ȥ��ǰ��Itemռ�Ŀ��

              while vItemNo < AItemNo do  // ��ȥ�м�Item�Ŀ��
              begin
                Self.SelectInfo.EndItemOffset := Self.SelectInfo.EndItemOffset - Self.Items[vItemNo].Length;
                Inc(vItemNo);
              end;

              Result := True;

              Break;
            end
            else  // ��ǰ���ŵ�û�ҵ�
            begin
              if Length(vOverText) >= Length(vKeyword) - 1 then  // ƴ�ӵĳ����˹ؼ��ֳ��ȣ�˵����ǰ�ı��ͺ����ƴ�Ӻ�û�п�ƥ��
                Break;
            end;

            Dec(vItemNo);
          end;
        end
        else  // �����ͬ������
        begin
          vItemNo := AItemNo;
          vConcatText := vText;
          vOverText := '';

          while (vItemNo < Self.Items.Count - 1)
            and (not Self.Items[vItemNo + 1].ParaFirst)
            and (Self.Items[vItemNo + 1].StyleNo > THCStyle.Null)
          do  // ͬ�κ����TextItem
          begin
            vText := LeftStr(Self.Items[vItemNo + 1].Text, Length(vKeyword) - 1);  // ȡ����ȹؼ�����һ���ַ����ȵģ��Ա�͵�ǰĩβ���һ��ƴ��
            vOverText := vOverText + vText;  // ��¼ƴ���˶��ٸ��ַ�
            vConcatText := vConcatText + vText;  // ƴ�Ӻ���ַ�
            if not AMatchCase then  // �����ִ�Сд
              vConcatText := UpperCase(vConcatText);

            vPos := Pos(vKeyword, vConcatText);
            if vPos > 0 then  // �ҵ���
            begin
              Self.SelectInfo.StartItemNo := AItemNo;
              Self.SelectInfo.StartItemOffset := AOffset + vPos - 1;

              Self.SelectInfo.EndItemNo := vItemNo + 1;
              Self.SelectInfo.EndItemOffset := vPos + Length(vKeyword) - 1  // �ؼ�������ַ���ƫ��λ��
                - (Self.Items[AItemNo].Length - AOffset);  // ��ȥ��ǰ��Itemռ�Ŀ��

              while vItemNo >= AItemNo + 1 do  // ��ȥ�м�Item�Ŀ��
              begin
                Self.SelectInfo.EndItemOffset := Self.SelectInfo.EndItemOffset - Self.Items[vItemNo].Length;
                Dec(vItemNo);
              end;

              Result := True;

              Break;
            end
            else  // ��ǰ���ŵ�û�ҵ�
            begin
              if Length(vOverText) >= Length(vKeyword) - 1 then  // ƴ�ӵĳ����˹ؼ��ֳ��ȣ�˵����ǰ�ı��ͺ����ƴ�Ӻ�û�п�ƥ��
                Break;
            end;

            Inc(vItemNo);
          end;
        end;
      end;
    end;
  end;
  {$ENDREGION}

var
  i, vItemNo, vOffset: Integer;
begin
  Result := False;

  if not AMatchCase then  // �����ִ�Сд
    vKeyword := UpperCase(AKeyword)
  else
    vKeyword := AKeyword;

  if Self.SelectInfo.StartItemNo < 0 then
  begin
    vItemNo := 0;
    vOffset := 0;
  end
  else
  if Self.SelectInfo.EndItemNo >= 0 then
  begin
    vItemNo := Self.SelectInfo.EndItemNo;
    vOffset := Self.SelectInfo.EndItemOffset;
  end
  else
  begin
    vItemNo := Self.SelectInfo.StartItemNo;
    vOffset := Self.SelectInfo.StartItemOffset;
  end;

  Result := DoSearchByOffset(vItemNo, vOffset);

  if not Result then
  begin
    if AForward then  // ��ǰ��
    begin
      for i := vItemNo - 1 downto 0 do
      begin
        if DoSearchByOffset(i, GetItemOffsetAfter(i)) then
        begin
          Result := True;
          Break;
        end;
      end;
    end
    else  // �����
    begin
      for i := vItemNo + 1 to Self.Items.Count - 1 do
      begin
        if DoSearchByOffset(i, 0) then
        begin
          Result := True;
          Break;
        end;
      end;
    end
  end;

  if not Result then  // û�ҵ�
  begin
    if Self.SelectInfo.EndItemNo >= 0 then
    begin
      if not AForward then  // �����
      begin
        Self.SelectInfo.StartItemNo := Self.SelectInfo.EndItemNo;
        Self.SelectInfo.StartItemOffset := Self.SelectInfo.EndItemOffset;
      end;

      Self.SelectInfo.EndItemNo := -1;
      Self.SelectInfo.EndItemOffset := -1;
    end;
  end;

  Self.Style.UpdateInfoRePaint;
  Self.Style.UpdateInfoReCaret;
end;

procedure THCViewData.SelectFirstItemBeforWithCaret;
begin
  ReSetSelectAndCaret(0, 0);
end;

procedure THCViewData.SelectItemAfterWithCaret(const AItemNo: Integer);
begin
  ReSetSelectAndCaret(AItemNo);
end;

procedure THCViewData.SelectLastItemAfterWithCaret;
begin
  SelectItemAfterWithCaret(Items.Count - 1);
end;

procedure THCViewData.SetSelectBound(const AStartNo, AStartOffset, AEndNo,
  AEndOffset: Integer; const ASilence: Boolean = True);
var
  vStartNo, vEndNo, vStartOffset, vEndOffset: Integer;
begin
  if AEndNo < 0 then  // ѡ��һ����
  begin
    vStartNo := AStartNo;
    vStartOffset := AStartOffset;
    vEndNo := -1;
    vEndOffset := -1;
  end
  else
  if AEndNo >= AStartNo then  // ��ǰ����ѡ��
  begin
    vStartNo := AStartNo;
    vEndNo := AEndNo;

    if AEndNo = AStartNo then  // ͬһ��Item
    begin
      if AEndOffset >= AStartOffset then  // ����λ������ʼ����
      begin
        vStartOffset := AStartOffset;
        vEndOffset := AEndOffset;
      end
      else  // ����λ������ʼǰ��
      begin
        vStartOffset := AEndOffset;
        vEndOffset := AStartOffset;
      end;
    end
    else  // ����ͬһ��Item
    begin
      vStartOffset := AStartOffset;
      vEndOffset := AEndOffset;
    end;
  end
  else  // AEndNo < AStartNo �Ӻ���ǰѡ��
  begin
    vStartNo := AEndNo;
    vStartOffset := AEndOffset;

    vEndNo := AStartNo;
    vEndOffset := vStartOffset;
  end;

  SelectInfo.StartItemNo := AStartNo;
  SelectInfo.StartItemOffset := AStartOffset;

  if (vEndNo < 0)
    or ((vEndNo = vStartNo) and (vEndOffset = vStartOffset))
  then
  begin
    SelectInfo.EndItemNo := -1;
    SelectInfo.EndItemOffset := -1;
  end
  else
  begin
    SelectInfo.EndItemNo := vEndNo;
    SelectInfo.EndItemOffset := vEndOffset;
  end;

  //FSelectSeekNo  �����Ҫȷ�� FSelectSeekNo���˷������ƶ���CustomRichData
  if not ASilence then
    ReSetSelectAndCaret(SelectInfo.StartItemNo, SelectInfo.StartItemOffset, True);
end;

procedure THCViewData.TraverseItem(const ATraverse: TItemTraverse);
var
  i: Integer;
begin
  if ATraverse <> nil then
  begin
    for i := 0 to Items.Count - 1 do
    begin
      if ATraverse.Stop then Break;

      ATraverse.Process(Self, i, ATraverse.Tag, ATraverse.Stop);
      if Items[i].StyleNo < THCStyle.Null then
        (Items[i] as THCCustomRectItem).TraverseItem(ATraverse);
    end;
  end;
end;

{ THCDomainInfo }

procedure THCDomainInfo.Clear;
begin
  FBeginNo := -1;
  FEndNo := -1;
end;

function THCDomainInfo.Contain(const AItemNo: Integer): Boolean;
begin
  Result := (AItemNo >= FBeginNo) and (AItemNo <= FEndNo);
end;

constructor THCDomainInfo.Create;
begin
  Clear;
end;

end.
