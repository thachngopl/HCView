{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{         ֧�ֳ������ָ��������ĵ��������Ԫ          }
{                                                       }
{*******************************************************}

unit HCUndoData;

interface

uses
  Windows, Classes, HCCommon, HCUndo, HCFormatData, HCItem, HCStyle;

type
  THCUndoData = class(THCFormatData)  // ֧�ֳ����ָ����ܵ�Data
  private
    FFormatFirstItemNo, FFormatFirstDrawItemNo, FFormatLastItemNo,
      FUndoGroupCount, FItemAddCount: Integer;
    procedure DoUndoRedo(const AUndo: THCCustomUndo);
  protected
    // Item��������Ͷ�ȡ�¼�
    procedure SaveItemToStreamAlone(const AItem: THCCustomItem; const AStream: TStream);

    /// <summary> �����м���һ��Item�����ItemΪnil����ᴴ���������� </summary>
    /// <param name="AStream"></param>
    /// <param name="AItem"></param>
    procedure LoadItemFromStreamAlone(const AStream: TStream; var AItem: THCCustomItem);

    { �����ָ���ط���+ }
    procedure Undo_New;
    procedure Undo_GroupBegin(const AItemNo, AOffset: Integer);
    procedure Undo_GroupEnd(const AItemNo, AOffset: Integer);

    /// <summary> ɾ��Text </summary>
    /// <param name="AItemNo">��������ʱ��ItemNo</param>
    /// <param name="AOffset">ɾ������ʼλ��</param>
    /// <param name="AText"></param>
    procedure UndoAction_DeleteBackText(const AItemNo, AOffset: Integer; const AText: string);
    procedure UndoAction_DeleteText(const AItemNo, AOffset: Integer; const AText: string);
    procedure UndoAction_InsertText(const AItemNo, AOffset: Integer; const AText: string);

    /// <summary> ɾ��ָ����Item </summary>
    /// <param name="AItemNo">��������ʱ��ItemNo</param>
    /// <param name="AOffset">��������ʱ��Offset</param>
    procedure UndoAction_DeleteItem(const AItemNo, AOffset: Integer);

    /// <summary> ����Item��ָ��λ�� </summary>
    /// <param name="AItemNo">��������ʱ��ItemNo</param>
    /// <param name="AOffset">��������ʱ��Offset</param>
    procedure UndoAction_InsertItem(const AItemNo, AOffset: Integer);
    procedure UndoAction_ItemStyle(const AItemNo, AOffset, ANewStyleNo: Integer);
    procedure UndoAction_ItemParaFirst(const AItemNo, AOffset: Integer; const ANewParaFirst: Boolean);

    procedure UndoAction_ItemSelf(const AItemNo, AOffset: Integer);
    procedure UndoAction_ItemMirror(const AItemNo, AOffset: Integer);
    { �����ָ���ط���- }
  public
    constructor Create(const AStyle: THCStyle); override;
    procedure Clear; override;
    procedure Undo(const AUndo: THCCustomUndo); virtual;
    procedure Redo(const ARedo: THCCustomUndo); virtual;
  end;

implementation

uses
  SysUtils, HCRectItem, HCTextStyle, HCParaStyle;

{ THCUndoData }

procedure THCUndoData.Clear;
var
  i: Integer;
  vUndoList: THCUndoList;
begin
  if Items.Count > 0 then
  begin
    vUndoList := GetUndoList;
    if Assigned(vUndoList) and vUndoList.Enable then
    begin
      Undo_New;
      for i := Items.Count - 1 downto 0 do
        UndoAction_DeleteItem(i, 0);
    end;
  end;
  inherited Clear;
end;

constructor THCUndoData.Create(const AStyle: THCStyle);
begin
  inherited Create(AStyle);
  FUndoGroupCount := 0;
  FItemAddCount := 0;
end;

procedure THCUndoData.DoUndoRedo(const AUndo: THCCustomUndo);
var
  vCaretItemNo, vCaretOffset, vCaretDrawItemNo: Integer;

  procedure DoUndoRedoAction(const AAction: THCCustomUndoAction;
    const AIsUndo: Boolean);

    procedure UndoRedoDeleteBackText;
    var
      vAction: THCTextUndoAction;
      vText: string;
      vLen: Integer;
    begin
      vAction := AAction as THCTextUndoAction;
      vCaretItemNo := vAction.ItemNo;
      vLen := Length(vAction.Text);
      vText := Items[vAction.ItemNo].Text;
      if AIsUndo then
      begin
        Insert(vAction.Text, vText, vAction.Offset);
        vCaretOffset := vAction.Offset + vLen - 1;
      end
      else
      begin
        Delete(vText, vAction.Offset, vLen);
        vCaretOffset := vAction.Offset - 1;
      end;

      Items[vAction.ItemNo].Text := vText;
    end;

    procedure UndoRedoDeleteText;
    var
      vAction: THCTextUndoAction;
      vText: string;
      vLen: Integer;
    begin
      vAction := AAction as THCTextUndoAction;
      vCaretItemNo := vAction.ItemNo;
      vLen := Length(vAction.Text);
      vText := Items[vAction.ItemNo].Text;
      if AIsUndo then
        Insert(vAction.Text, vText, vAction.Offset)
      else
        Delete(vText, vAction.Offset, vLen);

      vCaretOffset := vAction.Offset - 1;
      Items[vAction.ItemNo].Text := vText;
    end;

    procedure UndoRedoInsertText;
    var
      vAction: THCTextUndoAction;
      vText: string;
      vLen: Integer;
    begin
      vAction := AAction as THCTextUndoAction;
      vCaretItemNo := vAction.ItemNo;
      vText := Items[vAction.ItemNo].Text;;
      vLen := Length(vAction.Text);

      if AIsUndo then
      begin
        Delete(vText, vAction.Offset, vLen);
        vCaretOffset := vAction.Offset - 1;
      end
      else
      begin
        Insert(vAction.Text, vText, vAction.Offset);
        vCaretOffset := vAction.Offset + vLen - 1;
      end;

      Items[vAction.ItemNo].Text := vText;
    end;

    procedure UndoRedoDeleteItem;
    var
      vAction: THCItemUndoAction;
      vItem: THCCustomItem;
    begin
      vAction := AAction as THCItemUndoAction;
      vCaretItemNo := vAction.ItemNo;

      if AIsUndo then  // ����
      begin
        vItem := nil;
        LoadItemFromStreamAlone(vAction.ItemStream, vItem);
        Items.Insert(vAction.ItemNo, vItem);
        Inc(FItemAddCount);

        vCaretOffset := vAction.Offset;
      end
      else  // ����
      begin
        Items.Delete(vAction.ItemNo);
        Dec(FItemAddCount);

        if vCaretItemNo > 0 then
        begin
          Dec(vCaretItemNo);

          if Items[vCaretItemNo].StyleNo > THCStyle.Null then
            vCaretOffset := Items[vCaretItemNo].Length
          else
            vCaretOffset := OffsetAfter;
        end
        else
          vCaretOffset := 0;
      end;
    end;

    procedure UndoRedoInsertItem;
    var
      vAction: THCItemUndoAction;
      vItem: THCCustomItem;
    begin
      vAction := AAction as THCItemUndoAction;
      vCaretItemNo := vAction.ItemNo;

      if AIsUndo then  // ����
      begin
        Items.Delete(vAction.ItemNo);
        Dec(FItemAddCount);

        if vCaretItemNo > 0 then
        begin
          Dec(vCaretItemNo);
          if Items[vCaretItemNo].StyleNo > THCStyle.Null then
            vCaretOffset := Items[vCaretItemNo].Length
          else
            vCaretOffset := OffsetAfter;
        end
        else
          vCaretOffset := 0;
      end
      else  // ����
      begin
        vItem := nil;
        LoadItemFromStreamAlone(vAction.ItemStream, vItem);
        Items.Insert(vAction.ItemNo, vItem);
        Inc(FItemAddCount);

        vCaretItemNo := vAction.ItemNo;
        if Items[vCaretItemNo].StyleNo > THCStyle.Null then
          vCaretOffset := Items[vCaretItemNo].Length
        else
          vCaretOffset := OffsetAfter;

        vCaretDrawItemNo := (AUndo as THCDataUndo).CaretDrawItemNo + 1;
      end;
    end;

    procedure UndoRedoItemProperty;
    var
      vAction: THCItemPropertyUndoAction;
      vItem: THCCustomItem;
    begin
      vAction := AAction as THCItemPropertyUndoAction;
      vCaretItemNo := vAction.ItemNo;
      vCaretOffset := vAction.Offset;
      vItem := Items[vAction.ItemNo];

      case vAction.ItemProperty of
        uipStyleNo:
          begin
            if AIsUndo then
              vItem.StyleNo := (vAction as THCItemStyleUndoAction).OldStyleNo
            else
              vItem.StyleNo := (vAction as THCItemStyleUndoAction).NewStyleNo;
          end;

        uipParaNo:
          begin
            if AIsUndo then
              vItem.ParaNo := (vAction as THCItemParaUndoAction).OldParaNo
            else
              vItem.ParaNo := (vAction as THCItemParaUndoAction).NewParaNo;
          end;

        uipParaFirst:
          begin
            if AIsUndo then
              vItem.ParaFirst := (vAction as THCItemParaFirstUndoAction).OldParaFirst
            else
              vItem.ParaFirst := (vAction as THCItemParaFirstUndoAction).NewParaFirst;
          end;
      end;
    end;

    procedure UndoRedoItemSelf;
    var
      vAction: THCItemSelfUndoAction;
    begin
      vAction := AAction as THCItemSelfUndoAction;
      vCaretItemNo := vAction.ItemNo;
      vCaretOffset := vAction.Offset;
      if AIsUndo then
        Items[vCaretItemNo].Undo(vAction)
      else
        Items[vCaretItemNo].Redo(vAction);
    end;

    procedure UndoRedoItemMirror;
    var
      vAction: THCItemUndoAction;
      vItem: THCCustomItem;
    begin
      vAction := AAction as THCItemUndoAction;
      vCaretItemNo := vAction.ItemNo;
      vCaretOffset := vAction.Offset;
      vItem := Items[vCaretItemNo];
      if AIsUndo then
        LoadItemFromStreamAlone(vAction.ItemStream, vItem)
      else
        LoadItemFromStreamAlone(vAction.ItemStream, vItem);
    end;

  begin
    case AAction.Tag of
      uatDeleteBackText: UndoRedoDeleteBackText;
      uatDeleteText: UndoRedoDeleteText;
      uatInsertText: UndoRedoInsertText;
      uatDeleteItem: UndoRedoDeleteItem;
      uatInsertItem: UndoRedoInsertItem;
      uatItemProperty: UndoRedoItemProperty;
      uatItemSelf: UndoRedoItemSelf;
      uatItemMirror: UndoRedoItemMirror;
    end;
  end;

  function GetActionAffect(const AAction: THCCustomUndoAction): Integer;
  begin
    Result := AAction.ItemNo;
    case AAction.Tag of
      uatDeleteItem:
        begin
          if AUndo.IsUndo and (Result > 0) then
            Dec(Result);
        end;

      uatInsertItem:
        begin
          if (not AUndo.IsUndo) and (Result > Items.Count - 1) then
            Dec(Result);
        end;
    else
      if Result > Items.Count - 1 then
        Result := Items.Count - 1;
    end;
  end;

var
  i: Integer;
  vUndoList: THCUndoList;
begin
  if AUndo is THCUndoGroupEnd then  // �����(��Actions)
  begin
    if AUndo.IsUndo then  // �鳷��(��Action)
    begin
      if FUndoGroupCount = 0 then  // �鳷����ʼ
      begin
        vUndoList := GetUndoList;
        FFormatFirstItemNo := (vUndoList[vUndoList.CurGroupBeginIndex] as THCUndoGroupBegin).ItemNo;
        FFormatLastItemNo := (vUndoList[vUndoList.CurGroupEndIndex] as THCUndoGroupEnd).ItemNo;
        {for i := vUndoList.CurGroupEndIndex - 1 downto vUndoList.CurGroupBeginIndex + 1 do
        begin
          vUndo := vUndoList[i];
          for j := vUndo.Actions.Count - 1 downto 0 do
          begin
            if FFormatFirstItemNo > vUndo.Actions[j].ItemNo then
              FFormatFirstItemNo := vUndo.Actions[j].ItemNo;

            if FFormatLastItemNo < vUndo.Actions[j].ItemNo then
              FFormatLastItemNo := vUndo.Actions[j].ItemNo;
          end;
        end;}
        if FFormatFirstItemNo <> FFormatLastItemNo then
        begin
          FFormatFirstItemNo := GetParaFirstItemNo(FFormatFirstItemNo);  // ȡ�ε�һ��Ϊ��ʼ
          FFormatFirstDrawItemNo := Items[FFormatFirstItemNo].FirstDItemNo;
          FFormatLastItemNo := GetParaLastItemNo(FFormatLastItemNo);  // ȡ�����һ��Ϊ����
        end
        else
          GetFormatRange(FFormatFirstItemNo, 1, FFormatFirstDrawItemNo, FFormatLastItemNo);

        FormatPrepare(FFormatFirstDrawItemNo, FFormatLastItemNo);

        SelectInfo.Initialize;
        Self.InitializeField;
        FItemAddCount := 0;
      end;

      Inc(FUndoGroupCount);  // �����鳷������
    end
    else  // ��ָ�����
    begin
      Dec(FUndoGroupCount);  // ������ָ�����

      if FUndoGroupCount = 0 then  // ��ָ�����
      begin
        ReFormatData(FFormatFirstDrawItemNo, FFormatLastItemNo + FItemAddCount, FItemAddCount);

        SelectInfo.StartItemNo := (AUndo as THCUndoGroupEnd).ItemNo;
        SelectInfo.StartItemOffset := (AUndo as THCUndoGroupEnd).Offset;
        CaretDrawItemNo := (AUndo as THCUndoGroupEnd).CaretDrawItemNo;

        Style.UpdateInfoReCaret;
        Style.UpdateInfoRePaint;
      end;
    end;

    Exit;
  end
  else
  if AUndo is THCUndoGroupBegin then  // �鿪ʼ
  begin
    if AUndo.IsUndo then  // �鳷��(��Action)
    begin
      Dec(FUndoGroupCount);  // ���ٳ�������

      if FUndoGroupCount = 0 then  // �鳷������
      begin
        ReFormatData(FFormatFirstDrawItemNo, FFormatLastItemNo + FItemAddCount, FItemAddCount);

        SelectInfo.StartItemNo := (AUndo as THCUndoGroupBegin).ItemNo;
        SelectInfo.StartItemOffset := (AUndo as THCUndoGroupBegin).Offset;
        CaretDrawItemNo := (AUndo as THCUndoGroupBegin).CaretDrawItemNo;

        Style.UpdateInfoReCaret;
        Style.UpdateInfoRePaint;
      end;
    end
    else  // ��ָ�(��Action)
    begin
      if FUndoGroupCount = 0 then  // ��ָ���ʼ
      begin
        FFormatFirstItemNo := (AUndo as THCUndoGroupBegin).ItemNo;
        FFormatFirstDrawItemNo := Items[FFormatFirstItemNo].FirstDItemNo;
        FFormatLastItemNo := FFormatFirstItemNo;
        FormatPrepare(FFormatFirstDrawItemNo, FFormatLastItemNo);

        SelectInfo.Initialize;
        Self.InitializeField;
        FItemAddCount := 0;
      end;

      Inc(FUndoGroupCount);  // ������ָ�����
    end;

    Exit;
  end;

  if AUndo.Actions.Count = 0 then Exit;  // �������û��Action���ɴ˴�����

  if FUndoGroupCount = 0 then
  begin
    SelectInfo.Initialize;
    Self.InitializeField;
    FItemAddCount := 0;
    vCaretDrawItemNo := (AUndo as THCDataUndo).CaretDrawItemNo;

    if AUndo.Actions.First.ItemNo > AUndo.Actions.Last.ItemNo then
    begin
      FFormatFirstItemNo := GetParaFirstItemNo(GetActionAffect(AUndo.Actions.Last));
      FFormatLastItemNo := GetParaLastItemNo(GetActionAffect(AUndo.Actions.First));
    end
    else
    begin
      FFormatFirstItemNo := GetParaFirstItemNo(GetActionAffect(AUndo.Actions.First));
      FFormatLastItemNo := GetParaLastItemNo(GetActionAffect(AUndo.Actions.Last));
    end;

    FFormatFirstDrawItemNo := Items[FFormatFirstItemNo].FirstDItemNo;
    FormatPrepare(FFormatFirstDrawItemNo, FFormatLastItemNo);
  end;

  if AUndo.IsUndo then  // ����
  begin
    for i := AUndo.Actions.Count - 1 downto 0 do
      DoUndoRedoAction(AUndo.Actions[i], True);
  end
  else  // ����
  begin
    for i := 0 to AUndo.Actions.Count - 1 do
      DoUndoRedoAction(AUndo.Actions[i], False);
  end;

  //if Items.Count = 0 then
  //  DrawItems.Clear;  // ���ں���յ�Group�������м价�ڻ������Item�����

  if FUndoGroupCount = 0 then
  begin
    ReFormatData(FFormatFirstDrawItemNo, FFormatLastItemNo + FItemAddCount, FItemAddCount);

    if vCaretDrawItemNo < 0 then
      vCaretDrawItemNo := GetDrawItemNoByOffset(vCaretItemNo, vCaretOffset)
    else
    if vCaretDrawItemNo > Self.DrawItems.Count - 1 then
      vCaretDrawItemNo := Self.DrawItems.Count - 1;

    CaretDrawItemNo := vCaretDrawItemNo;

    Style.UpdateInfoReCaret;
    Style.UpdateInfoRePaint;
  end;

  // Ϊ���Ч�ʣ��鳷����ָ�ʱ��ֻ�����һ��(��ͷ��β)���ٽ��Ƹ�ʽ���ͼ���ҳ��
  // ������Ҫÿ���ĳ�����ָ�����¼SelectInfo���Ա����һ��(��ͷ��β)����ʽ����
  // ��ҳʱ�б䶯ǰ�����λ��
  SelectInfo.StartItemNo := vCaretItemNo;
  SelectInfo.StartItemOffset := vCaretOffset;
end;

procedure THCUndoData.LoadItemFromStreamAlone(const AStream: TStream;
  var AItem: THCCustomItem);
var
  vFileExt: string;
  viVersion: Word;
  vLang: Byte;
  vStyleNo, vParaNo: Integer;
  vTextStyle: THCTextStyle;
  vParaStyle: THCParaStyle;
begin
  AStream.Position := 0;
  _LoadFileFormatAndVersion(AStream, vFileExt, viVersion, vLang);  // �ļ���ʽ�Ͱ汾
  if (vFileExt <> HC_EXT) and (vFileExt <> 'cff.') then
    raise Exception.Create('����ʧ�ܣ�����' + HC_EXT + '�ļ���');

  AStream.ReadBuffer(vStyleNo, SizeOf(vStyleNo));

  if not Assigned(AItem) then
    AItem := CreateItemByStyle(vStyleNo);

  AItem.LoadFromStream(AStream, nil, viVersion);

  if vStyleNo > THCStyle.Null then
  begin
    vTextStyle := THCTextStyle.Create;
    try
      vTextStyle.LoadFromStream(AStream, viVersion);
      vStyleNo := Style.GetStyleNo(vTextStyle, True);
      AItem.StyleNo := vStyleNo;
    finally
      FreeAndNil(vTextStyle);
    end;
  end;

  vParaStyle := THCParaStyle.Create;
  try
    vParaStyle.LoadFromStream(AStream, viVersion);
    vParaNo := Style.GetParaNo(vParaStyle, True);
  finally
    FreeAndNil(vParaStyle);
  end;

  AItem.ParaNo := vParaNo;
end;

procedure THCUndoData.Redo(const ARedo: THCCustomUndo);
begin
  DoUndoRedo(ARedo);
end;

procedure THCUndoData.SaveItemToStreamAlone(const AItem: THCCustomItem;
  const AStream: TStream);
begin
  _SaveFileFormatAndVersion(AStream);
  AItem.SaveToStream(AStream);
  if AItem.StyleNo > THCStyle.Null then
    Style.TextStyles[AItem.StyleNo].SaveToStream(AStream);

  Style.ParaStyles[AItem.ParaNo].SaveToStream(AStream);
end;

procedure THCUndoData.Undo(const AUndo: THCCustomUndo);
begin
  DoUndoRedo(AUndo);
end;

procedure THCUndoData.UndoAction_DeleteItem(const AItemNo,
  AOffset: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vItemAction: THCItemUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vItemAction := vUndo.ActionAppend(uatDeleteItem, AItemNo, AOffset) as THCItemUndoAction;
      SaveItemToStreamAlone(Items[AItemNo], vItemAction.ItemStream);
    end;
  end;
end;

procedure THCUndoData.UndoAction_DeleteText(const AItemNo, AOffset: Integer;
  const AText: string);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vTextAction: THCTextUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vTextAction := vUndo.ActionAppend(uatDeleteText, AItemNo, AOffset) as THCTextUndoAction;
      vTextAction.Text := AText;
    end;
  end;
end;

procedure THCUndoData.UndoAction_DeleteBackText(const AItemNo, AOffset: Integer;
  const AText: string);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vTextAction: THCTextUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vTextAction := vUndo.ActionAppend(uatDeleteBackText, AItemNo, AOffset) as THCTextUndoAction;
      vTextAction.Text := AText;
    end;
  end;
end;

procedure THCUndoData.UndoAction_InsertItem(const AItemNo,
  AOffset: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vItemAction: THCItemUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vItemAction := vUndo.ActionAppend(uatInsertItem, AItemNo, AOffset) as THCItemUndoAction;
      SaveItemToStreamAlone(Items[AItemNo], vItemAction.ItemStream);
    end;
  end;
end;

procedure THCUndoData.UndoAction_InsertText(const AItemNo, AOffset: Integer;
  const AText: string);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vTextAction: THCTextUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vTextAction := vUndo.ActionAppend(uatInsertText, AItemNo, AOffset) as THCTextUndoAction;
      vTextAction.Text := AText;
    end;
  end;
end;

procedure THCUndoData.UndoAction_ItemMirror(const AItemNo,
  AOffset: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vItemAction: THCItemUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vItemAction := vUndo.ActionAppend(uatItemMirror, AItemNo, AOffset) as THCItemUndoAction;
      SaveItemToStreamAlone(Items[AItemNo], vItemAction.ItemStream);
    end;
  end;
end;

procedure THCUndoData.UndoAction_ItemParaFirst(const AItemNo,
  AOffset: Integer; const ANewParaFirst: Boolean);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vItemAction: THCItemParaFirstUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vItemAction := THCItemParaFirstUndoAction.Create;
      vItemAction.ItemNo := AItemNo;
      vItemAction.Offset := AOffset;
      vItemAction.OldParaFirst := Items[AItemNo].ParaFirst;
      vItemAction.NewParaFirst := ANewParaFirst;

      vUndo.Actions.Add(vItemAction);
    end;
  end;
end;

procedure THCUndoData.UndoAction_ItemSelf(const AItemNo, AOffset: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
      vUndo.ActionAppend(uatItemSelf, AItemNo, AOffset);
  end;
end;

procedure THCUndoData.UndoAction_ItemStyle(const AItemNo, AOffset, ANewStyleNo: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vItemAction: THCItemStyleUndoAction;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vItemAction := THCItemStyleUndoAction.Create;
      vItemAction.ItemNo := AItemNo;
      vItemAction.Offset := AOffset;
      vItemAction.OldStyleNo := Items[AItemNo].StyleNo;
      vItemAction.NewStyleNo := ANewStyleNo;

      vUndo.Actions.Add(vItemAction);
    end;
  end;
end;

procedure THCUndoData.Undo_GroupBegin(const AItemNo, AOffset: Integer);
var
  vUndoList: THCUndoList;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
    vUndoList.UndoGroupBegin(AItemNo, AOffset);
end;

procedure THCUndoData.Undo_GroupEnd(const AItemNo, AOffset: Integer);
var
  vUndoList: THCUndoList;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
    vUndoList.UndoGroupEnd(AItemNo, AOffset);
end;

procedure THCUndoData.Undo_New;
var
  vUndoList: THCUndoList;
  vUndo: THCUndo;
begin
  vUndoList := GetUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    vUndo := vUndoList.UndoNew;
    if vUndo is THCDataUndo then
      (vUndo as THCDataUndo).CaretDrawItemNo := CaretDrawItemNo;
  end;
end;

end.
