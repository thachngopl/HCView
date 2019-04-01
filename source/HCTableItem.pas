{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                     ���ʵ�ֵ�Ԫ                      }
{                                                       }
{*******************************************************}

unit HCTableItem;

interface

uses
  Classes, SysUtils, Types, Graphics, Controls, Generics.Collections, HCDrawItem,
  HCRectItem, HCTableRow, HCCustomData, HCRichData, HCTableCell, HCTableCellData,
  HCViewData, HCTextStyle, HCCommon, HCParaStyle, HCStyleMatch, HCItem, HCStyle,
  HCList, HCUndo, HCXml;

type
  TSelectCellRang = class
  strict private
    FStartRow,  // ѡ����ʼ��
    FStartCol,  // ѡ����ʼ��
    FEndRow,    // ѡ�н�����
    FEndCol     // ѡ�н�����
      : Integer;
  public
    constructor Create;

    /// <summary> ��ʼ���ֶκͱ��� </summary>
    procedure Initialize;

    /// <summary> ��ͬһ��Ԫ�б༭ </summary>
    function EditCell: Boolean;

    /// <summary> ѡ����ͬһ�� </summary>
    function SameRow: Boolean;

    /// <summary> ѡ����ͬһ�� </summary>
    function SameCol: Boolean;

    /// <summary> ѡ��1-n����Ԫ�� </summary>
    function SelectExists: Boolean;
    property StartRow: Integer read FStartRow write FStartRow;
    property StartCol: Integer read FStartCol write FStartCol;
    property EndRow: Integer read FEndRow write FEndRow;
    property EndCol: Integer read FEndCol write FEndCol;
  end;

  TTableSite = (
    tsOutside,  // �������
    tsCell,  // ��Ԫ����
    tsBorderLeft,{ֻ�е�һ��ʹ�ô�Ԫ��}
    tsBorderTop,  {ֻ�е�һ��ʹ�ô�Ԫ��}
    tsBorderRight,  // ��X���ұ�
    tsBorderBottom  // ��X���±�
  );

  //PResizeInfo = ^TResizeInfo;
  TResizeInfo = record  // ������Ϣ
    TableSite: TTableSite;
    DestX, DestY: Integer;
  end;

  TPageBreak = class  // ��ҳ��Ϣ
    /// <summary> �ڴ�ҳ��β��ҳ </summary>
    PageIndex,
    Row,  // ��ҳ��
    BreakSeat,  // ��ҳʱ�����и��з�ҳ�ض�λ�þ����񶥲���������
    BreakBottom  // ��ҳʱ��ҳ�ײ�λ�þ��ҳ�������ľ���(��ҳ�ж��ٿռ������ű��)
      : Integer;
  end;

  TRowAddEvent = procedure(const ARow: THCTableRow) of object;

  THCTableRows = Class(TObjectList<THCTableRow>)
  private
    FOnRowAdd: TRowAddEvent;
  protected
    procedure Notify(const Value: THCTableRow; Action: TCollectionNotification); override;
  public
    property OnRowAdd: TRowAddEvent read FOnRowAdd write FOnRowAdd;
  end;

  TOutsideInfo = record  // ���������Ϣ
    Row: Integer;  // ����λ�ô���Ӧ����
    Leftside: Boolean;  // True����� False���ұ�
  end;

  THCTableItem = class(THCResizeRectItem)
  private
    FBorderWidth,  // �߿���(Ҫ�󲻴�����С�иߣ������ҳ�����������)
    FCellHPadding,  // ��Ԫ������ˮƽƫ��
    FCellVPadding   // ��Ԫ�����ݴ�ֱƫ��(���ܴ�����͵�DrawItem�߶ȣ������Ӱ���ҳ)
      : Byte;  // ��Ԫ�����ݺ͵�Ԫ��߿�ľ���

    FOutsideInfo: TOutsideInfo;  // ����ڱ�����ұ�ʱ��Ӧ������Ϣ

    FMouseDownRow, FMouseDownCol,
    FMouseMoveRow, FMouseMoveCol,
    FMouseDownX, FMouseDownY,
    FFormatHeight
      : Integer;

    FResizeInfo: TResizeInfo;

    FBorderVisible, FMouseLBDowning, FSelecting, FDraging, FOutSelectInto,
    FLastChangeFormated  // ���䶯�Ѿ���ʽ������
      : Boolean;

    { ѡ����Ϣ(ֻ��ѡ����ʼ�ͽ����ж�>=0��˵����ѡ�ж����Ԫ��
     �ڵ�����Ԫ����ѡ��ʱ�����С�����ϢΪ-1 }
    FSelectCellRang: TSelectCellRang;
    FBorderColor: TColor;  // �߿���ɫ
    FRows: THCTableRows;  // ��
    FColWidths: TList<Integer>;  // ��¼���п��(���߿򡢺�FCellHPadding * 2)�������кϲ��ĵ�Ԫ���ȡ�Լ�ˮƽ��ʼ����λ��
    FPageBreaks: TObjectList<TPageBreak>;  // ��¼���з�ҳʱ����Ϣ

    procedure InitializeMouseInfo;

    procedure InitializeCellData(const ACellData: THCTableCellData);

    function DoCellDataGetRootData: THCCustomData;

    /// <summary> ����������ʱ </summary>
    procedure DoRowAdd(const ARow: THCTableRow);

    procedure CellChangeByAction(const ARow, ACol: Integer; const AProcedure: THCProcedure);

    /// <summary> ��ȡ��ǰ����ʽ���߶� </summary>
    /// <returns></returns>
    function GetFormatHeight: Integer;
    /// <summary> ��ȡ������ߵ�Ԫ��߶ȣ�������Ϊ����������Ԫ��ĸ߶Ⱥ��и� </summary>
    procedure CalcRowCellHeight(const ARow: Integer);
    /// <summary> �����кϲ��ĵ�Ԫ��߶�Ӱ�쵽���и߶� </summary>
    procedure CalcMergeRowHeightFrom(const ARow: Integer);
    function SrcCellDataDrawTopDistanceToDest(const ASrcRow, ADestRow: Integer): Integer;

    /// <summary> ����ָ����Ԫ����Ա�����ʼλ������(������ϲ����غϲ�����Ԫ�������) </summary>
    /// <param name="ARow"></param>
    /// <param name="ACol"></param>
    /// <returns></returns>
    function GetCellPostion(const ARow, ACol: Integer): TPoint;

    function ActiveDataResizing: Boolean;

    /// <summary> ȡ��ѡ�з�Χ�ڳ�ARow, ACol֮�ⵥԪ���ѡ��״̬(-1��ʾȫ��ȡ��) </summary>
    procedure DisSelectSelectedCell(const ARow: Integer = -1; const ACol: Integer = -1);

    procedure SetBorderWidth(const Value: Byte);
    procedure SetCellVPadding(const Value: Byte);
  protected
    function CanDrag: Boolean; override;
    function GetSelectComplate: Boolean; override;
    procedure SelectComplate; override;
    function GetResizing: Boolean; override;
    procedure SetResizing(const Value: Boolean); override;

    /// <summary> ��ָ����λ�û��Ʊ�� </summary>
    /// <param name="AStyle"></param>
    /// <param name="ADrawRect">����ʱ��Rect(���ADataScreenTop)</param>
    /// <param name="ADataDrawTop">Table������Data������ʼλ��(���ADataScreenTop����Ϊ����)</param>
    /// <param name="ADataDrawBottom">Table������Data������ʼλ��(���ADataScreenTop���ɳ���ADataScreenBottom)</param>
    /// <param name="ADataScreenTop">��ǰҳ������ʼλ��(����ڵ�0, 0��>=0)</param>
    /// <param name="ADataScreenBottom">��ǰҳ��Ļ�ײ�λ��(����ڵ�0, 0��<=���ڸ߶�)</param>
    /// <param name="ACanvas"></param>
    /// <param name="APaintInfo"></param>
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    //procedure PaintPartTo(const ACanvas: TCanvas; const ADrawLeft, ADrawTop, ADrawBottom, ADataScreenTop,
    //  ADataScreenBottom, AStartRow, AStartRowDataOffs, AEndRow, AEndRowDataOffs: Integer); overload;
    {procedure ConvertToDrawItems(const AItemNo, AOffs, AContentWidth,
      AContentHeight: Integer; var APos: TPoint; var APageIndex, ALastDNo: Integer);}
    // �̳�THCCustomItem���󷽷�
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure KillFocus; override;
    // �̳�TCustomRectItem���󷽷�
    procedure ApplySelectTextStyle(const AStyle: THCStyle; const AMatchStyle: THCStyleMatch); override;
    procedure ApplySelectParaStyle(const AStyle: THCStyle; const AMatchStyle: THCParaMatch); override;
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    /// <summary> ��������ʱ�ڲ��Ƿ���ָ����Key��Shif </summary>
    function WantKeyDown(const Key: Word; const Shift: TShiftState): Boolean; override;

    /// <summary> ���������Ϊ�����ҳ�к����м�������ƫ�ƺ󣬱Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer; override;
    function DeleteSelected: Boolean; override;
    procedure DisSelect; override;
    procedure MarkStyleUsed(const AMark: Boolean); override;
    procedure GetCaretInfo(var ACaretInfo: THCCaretInfo); override;
    procedure SetActive(const Value: Boolean); override;

    /// <summary> ��ȡ�����ָ���߶��ڵĽ���λ�ô��������¶�(��ʱû�õ�ע����) </summary>
    /// <param name="AHeight">ָ���ĸ߶ȷ�Χ</param>
    /// <param name="ADItemMostBottom">���һ����׶�DItem�ĵײ�λ��</param>
    //procedure GetPageFmtBottomInfo(const AHeight: Integer; var ADItemMostBottom: Integer); override;

    procedure DblClick(const X, Y: Integer); override;
    function CoordInSelect(const X, Y: Integer): Boolean; override;
    function GetTopLevelDataAt(const X, Y: Integer): THCCustomData; override;
    function GetActiveData: THCCustomData; override;
    function GetActiveItem: THCCustomItem; override;
    function GetActiveDrawItem: THCCustomDrawItem; override;
    function GetActiveDrawItemCoord: TPoint; override;
    function GetHint: string; override;

    function InsertText(const AText: string): Boolean; override;
    function InsertItem(const AItem: THCCustomItem): Boolean; override;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function IsSelectComplateTheory: Boolean; override;
    function SelectExists: Boolean; override;
    procedure TraverseItem(const ATraverse: TItemTraverse); override;

    // ����������ط���
    function DoSelfUndoNew: THCUndo; override;
    procedure DoSelfUndoDestroy(const AUndo: THCUndo); override;
    procedure DoSelfUndo(const AUndo: THCUndo); override;
    procedure DoSelfRedo(const ARedo: THCUndo); override;
    procedure Undo_ColResize(const ACol, AOldWidth, ANewWidth: Integer);
    procedure Undo_RowResize(const ARow, AOldHeight, ANewHeight: Integer);
    procedure Undo_MergeCells;

    function GetRowCount: Integer;
    function GetColCount: Integer;

    /// <summary> ��ȡָ�����з�Χʵ�ʶ�Ӧ�����з�Χ
    /// </summary>
    /// <param name="AStartRow"></param>
    /// <param name="AStartCol"></param>
    /// <param name="AEndRow"></param>
    /// <param name="AEndCol"></param>
    procedure AdjustCellRange(const AStartRow, AStartCol: Integer;
      var AEndRow, AEndCol: Integer);
    function MergeCells(const AStartRow, AStartCol, AEndRow, AEndCol: Integer):Boolean;
    function GetCells(ARow, ACol: Integer): THCTableCell;
    function GetColWidth(AIndex: Integer): Integer;
    procedure SetColWidth(AIndex: Integer; const AWidth: Integer);
    function InsertCol(const ACol, ACount: Integer): Boolean;
    function InsertRow(const ARow, ACount: Integer): Boolean;
    function DeleteCol(const ACol: Integer): Boolean;
    function DeleteRow(const ARow: Integer): Boolean;
  public
    //DrawItem: TCustomDrawItem;
    constructor Create(const AOwnerData: THCCustomData; const ARowCount, AColCount,
      AWidth: Integer); virtual;

    destructor Destroy; override;

    procedure Assign(Source: THCCustomItem); override;

    /// <summary> ��ǰλ�ÿ�ʼ����ָ�������� </summary>
    /// <param name="AKeyword">Ҫ���ҵĹؼ���</param>
    /// <param name="AForward">True����ǰ��False�����</param>
    /// <param name="AMatchCase">True�����ִ�Сд��False�������ִ�Сд</param>
    /// <returns>True���ҵ�</returns>
    function Search(const AKeyword: string; const AForward, AMatchCase: Boolean): Boolean; override;

    procedure CheckFormatPageBreakBefor; override;

    /// <summary> ����ҳ </summary>
    /// <param name="ADrawItemRectTop">����Ӧ��DrawItem��Rect.Top</param>
    /// <param name="ADrawItemRectTop">����Ӧ��DrawItem��Rect.Bottom</param>
    /// <param name="APageDataFmtTop">��ǰҳ�����ݶ���λ��</param>
    /// <param name="APageDataFmtBottom">��ǰҳ�����ݵײ�λ��</param>
    /// <param name="ACheckRow">��ǰҳ�����п�ʼ�Ű�</param>
    /// <param name="ABreakRow">��ǰҳ����ҳ������</param>
    /// <param name="AFmtOffset">����Ӧ��DrawItem��������ƫ�Ƶ���</param>
    /// <param name="ACellMaxInc">���ص�ǰҳ����Ϊ�˱ܿ���ҳλ�ö���ƫ�Ƶ����߶�(����ԭ��AFmtHeightIncΪ���ڷ���������)</param>
    procedure CheckFormatPageBreak(const APageIndex, ADrawItemRectTop,
      ADrawItemRectBottom, APageDataFmtTop, APageDataFmtBottom, AStartRow: Integer;
      var ABreakRow, AFmtOffset, ACellMaxInc: Integer); override;

    // ����Ͷ�ȡ
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure SaveSelectToStream(const AStream: TStream); override;  // inherited TCustomRect
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    function ToHtml(const APath: string): string; override;
    procedure ToXml(const ANode: IHCXMLNode); override;
    procedure ParseXml(const ANode: IHCXMLNode); override;

    /// <summary> ��ȡָ��λ�ô����С���(����Ǳ��ϲ���Ԫ���򷵻�Ŀ�굥Ԫ���С���) </summary>
    /// <param name="X">������</param>
    /// <param name="Y">������</param>
    /// <param name="ARow">���괦����</param>
    /// <param name="ACol">���괦����</param>
    ///  <param name="AReDest">��������Ǻϲ�Դ������Ŀ��</param>
    /// <returns></returns>
    function GetCellAt(const X, Y : Integer; var ARow, ACol: Integer;
      const AReDest: Boolean = True): TResizeInfo;

    procedure GetDestCell(const ARow, ACol: Cardinal; var ADestRow, ADestCol: Integer);
    procedure GetSourceCell(const ARow, ACol: Cardinal; var ASrcRow, ASrcCol: Integer);

    procedure SelectAll;

    /// <summary> �ж�ָ����Χ�ڵĵ�Ԫ���Ƿ���Ժϲ�(Ϊ�˸�����ϲ��˵����ƿ���״̬�ŵ�public����) </summary>
    /// <param name="AStartRow"></param>
    /// <param name="AStartCol"></param>
    /// <param name="AEndRow"></param>
    /// <param name="AEndCol"></param>
    /// <returns></returns>
    function CellsCanMerge(const AStartRow, AStartCol, AEndRow, AEndCol: Integer): Boolean;

    /// <summary> ָ�����Ƿ���ɾ�� </summary>
    function RowCanDelete(const ARow: Integer): Boolean;
    function CurRowCanDelete: Boolean;

    /// <summary> ָ�����Ƿ���ɾ�� </summary>
    function ColCanDelete(const ACol: Integer): Boolean;
    function CurColCanDelete: Boolean;

    /// <summary> ��ȡָ����Ԫ��ϲ���ĵ�Ԫ�� </summary>
    procedure GetMergeDest(const ARow, ACol: Integer; var ADestRow, ADestCol: Integer);

    /// <summary> ��ȡָ����Ԫ��ϲ���Ԫ���Data </summary>
    //function GetMergeDestCellData(const ARow, ACol: Integer): THCTableCellData;

    function MergeSelectCells: Boolean;
    function SelectedCellCanMerge: Boolean;

    function GetEditCell: THCTableCell; overload;
    procedure GetEditCell(var ARow, ACol: Integer); overload;

    function InsertRowAfter(const ACount: Integer): Boolean;
    function InsertRowBefor(const ACount: Integer): Boolean;
    function InsertColAfter(const ACount: Integer): Boolean;
    function InsertColBefor(const ACount: Integer): Boolean;
    function DeleteCurCol: Boolean;
    function DeleteCurRow: Boolean;
    function SplitCurRow: Boolean;
    function SplitCurCol: Boolean;

    property Cells[ARow, ACol: Integer]: THCTableCell read GetCells;
    property ColWidth[AIndex: Integer]: Integer read GetColWidth write SetColWidth;
    property Rows: THCTableRows read FRows;
    property RowCount: Integer read GetRowCount;
    property ColCount: Integer read GetColCount;
    property SelectCellRang: TSelectCellRang read FSelectCellRang;
    property BorderVisible: Boolean read FBorderVisible write FBorderVisible;
    property BorderWidth: Byte read FBorderWidth write SetBorderWidth;
    property CellHPadding: Byte read FCellHPadding write FCellHPadding;
    property CellVPadding: Byte read FCellVPadding write SetCellVPadding;
  end;

implementation

uses
  Math, Windows;

type
  /// <summary> �п�ҳ��Ϣ </summary>
  TColCross = class(TObject)
  public
    Col,  // ��Ԫ�����ڵ���
    DrawItemNo,  // ��ҳ��DrawItem
    VDrawOffset  // ��ҳDrawItem��ƫ��
      : Integer;
    //MergeSrc: Boolean;
    constructor Create;
  end;

{$I HCView.inc}

{ THCTableItem }

procedure THCTableItem.CalcMergeRowHeightFrom(const ARow: Integer);
var
  i, vR, vC, vExtraHeight, vDestRow, vDestCol, vH,
  vDestRow2, vDestCol2: Integer;
begin
  // Ϊ���ݷ�ҳʱ���¸�ʽ�����ô˷����������ж�FmtOffset�Ĵ���������Ҫ��FmtOffset
  for vR := ARow to RowCount - 1 do  // �������кϲ�����¸��еĸ߶�
  begin
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      if Cells[vR, vC].CellData = nil then  // ��ǰ��Ԫ�񱻺ϲ���
      begin
        if Cells[vR, vC].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
          Continue;

        GetMergeDest(vR, vC, vDestRow, vDestCol);  // ��ȡ���ϲ�Ŀ�굥Ԫ�������к�

        if vDestRow + Cells[vDestRow, vC].RowSpan = vR then  // Ŀ�굥Ԫ���кϲ����˽���
        begin
          vExtraHeight := FCellVPadding + Cells[vDestRow, vC].CellData.Height + FCellVPadding;  // Ŀ�굥Ԫ������±߿��ĸ߶�
          Cells[vDestRow, vC].Height := vExtraHeight;  // Ŀ�굥Ԫ������±߿��ĸ߶�
          vExtraHeight := vExtraHeight - FRows[vDestRow].Height - FBorderWidth;  // ���������Լ�������

          for i := vDestRow + 1 to vR - 1 do  // ��Ŀ����һ�е��ˣ��������к�������������
            vExtraHeight := vExtraHeight - FRows[i].FmtOffset - FRows[i].Height - FBorderWidth;

          if vExtraHeight > FRows[vR].FmtOffset + FRows[vR].Height then  // ������ʣ��ıȵ�ǰ�и�
          begin
            vH := vExtraHeight - FRows[vR].FmtOffset - FRows[vR].Height;  // �߶���
            FRows[vR].Height := vExtraHeight - FRows[vR].FmtOffset;  // ��ǰ�и߸�ֵ��ֵ(�ڲ�����Ԫ��߶Ȼᴦ��)

            for i := 0 to FRows[vR].ColCount - 1 do  // ��ǰ����Դ��ҪӰ��Ŀ�굥Ԫ��
            begin
              if FRows[vR].Cols[i].CellData = nil then  // Դ��
              begin
                GetMergeDest(vR, i, vDestRow2, vDestCol2);  // ��ȡĿ�굥Ԫ��
                if (vDestRow2 <> vDestRow) and (vDestCol2 <> vDestCol) then  // ���ǵ�ǰҪ�����Ŀ�굥Ԫ��
                  Cells[vDestRow2, i].Height := Cells[vDestRow2, i].Height + vH;
              end;
            end;
          end
          else  // ������ʣ���û�е�ǰ�иߣ��߶����ӵ���ǰ�еײ�������Ǻϲ��ĵ�Ԫ�����ݣ����ںϲ����������е����ݵײ�û�д��иߵ����
          begin
            Cells[vDestRow, vC].Height :=  // 2017-1-15_1.bmp��[1, 1]����cʱ[1, 0]��[1, 2]�����
              Cells[vDestRow, vC].Height + FRows[vR].FmtOffset + FRows[vR].Height - vExtraHeight;
          end;
        end;
      end;
    end;
  end;
end;

procedure THCTableItem.FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer);

  {$REGION 'FormatRow ��ʽ��ָ���и���Ԫ�񲢼��㵥Ԫ��߶�'}
  procedure FormatRow(const ARow: Cardinal);
  var
    vC, vWidth, i: Integer;
    vRow: THCTableRow;
  begin
    vRow := FRows[ARow];
    vRow.FmtOffset := 0;  // �ָ��ϴθ�ʽ�����ܵ�ƫ��
    // ��ʽ������Ԫ���е�Data
    for vC := 0 to vRow.ColCount - 1 do
    begin
      if vRow.Cols[vC].CellData <> nil then
      begin
        vWidth := FColWidths[vC];
        for i := 1 to vRow.Cols[vC].ColSpan do
          vWidth := vWidth + FBorderWidth + FColWidths[vC + i];

        vRow.Cols[vC].Width := vWidth;
        vRow.Cols[vC].CellData.Width := vWidth - FCellHPadding - FCellHPadding;
        vRow.Cols[vC].CellData.ReFormat;
      end
    end;
  end;
  {$ENDREGION}

var
  i, vR, vC
    : Integer;
begin
  if FLastChangeFormated then
  begin
    ClearFormatExtraHeight;
    Exit;
  end;

  for vR := 0 to RowCount - 1 do  // ��ʽ������
  begin
    FormatRow(vR);  // ��ʽ���У��������и߶�
    CalcRowCellHeight(vR);  // �������������кϲ������������߶ȸ���������
  end;
  FLastChangeFormated := True;

  CalcMergeRowHeightFrom(0);
  Self.Height := GetFormatHeight;  // ��������߶�

  // ����������
  i := FBorderWidth;
  for vC := 0 to FColWidths.Count - 1 do
    i := i + FColWidths[vC] + FBorderWidth;
  Width := i;
end;

constructor THCTableItem.Create(const AOwnerData: THCCustomData;
  const ARowCount, AColCount, AWidth: Integer);
var
  vRow: THCTableRow;
  i, vDataWidth: Integer;
begin
  inherited Create(AOwnerData);

  if ARowCount = 0 then
    raise Exception.Create('�쳣�����ܴ�������Ϊ0�ı��');
  if AColCount = 0 then
    raise Exception.Create('�쳣�����ܴ�������Ϊ0�ı��');

  GripSize := 2;
  FCellHPadding := 2;
  FCellVPadding := 2;
  FDraging := False;
  FBorderWidth := 1;
  FBorderColor := clBlack;
  FBorderVisible := True;

  StyleNo := THCStyle.Table;
  ParaNo := OwnerData.CurParaNo;
  CanPageBreak := True;
  FPageBreaks := TObjectList<TPageBreak>.Create;

  //FWidth := FRows[0].ColCount * (MinColWidth + FBorderWidth) + FBorderWidth;
  Height := ARowCount * (MinRowHeight + FBorderWidth) + FBorderWidth;
  FRows := THCTableRows.Create;
  FRows.OnRowAdd := DoRowAdd;  // �����ʱ�������¼�
  FSelectCellRang := TSelectCellRang.Create;
  Self.InitializeMouseInfo;
  //
  vDataWidth := AWidth - (AColCount + 1) * FBorderWidth;
  for i := 0 to ARowCount - 1 do
  begin
    vRow := THCTableRow.Create(OwnerData.Style, AColCount);
    vRow.SetRowWidth(vDataWidth);
    FRows.Add(vRow);
  end;
  FColWidths := TList<Integer>.Create;
  for i := 0 to AColCount - 1 do
    FColWidths.Add(FRows[0].Cols[i].Width);

  FMangerUndo := True;  // �Լ������Լ��ĳ����ͻָ�����
  FLastChangeFormated := False;
end;

function THCTableItem.CurColCanDelete: Boolean;
begin
  Result := (FSelectCellRang.EndCol < 0)
    and (FSelectCellRang.StartCol >= 0)
    and ColCanDelete(FSelectCellRang.StartCol);
end;

function THCTableItem.CurRowCanDelete: Boolean;
begin
  Result := (FSelectCellRang.EndRow < 0)
    and (FSelectCellRang.StartRow >= 0)
    and RowCanDelete(FSelectCellRang.StartRow);
end;

procedure THCTableItem.DblClick(const X, Y: Integer);
var
  vPt: TPoint;
begin
  if FSelectCellRang.EditCell then
  begin
    vPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.DblClick(
      X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
  end
  else
    inherited DblClick(X, Y);
end;

function THCTableItem.DeleteCol(const ACol: Integer): Boolean;
var
  i, vRow: Integer;
  viDestRow, viDestCol: Integer;
begin
  Result := False;

  if not ColCanDelete(ACol) then Exit;

  for vRow := 0 to RowCount - 1 do
  begin
    if FRows[vRow].Cols[ACol].ColSpan < 0 then  // �ϲ�Դ
    begin
      GetDestCell(vRow, ACol, viDestRow, viDestCol);  // Ŀ���С���
      for i := ACol + 1 to viDestCol + FRows[viDestRow].Cols[viDestCol].ColSpan do  // ��ǰ������ĺϲ�Դ����Ŀ���1
        FRows[vRow].Cols[i].ColSpan := FRows[vRow].Cols[i].ColSpan + 1;

      if vRow = viDestRow + FRows[viDestRow].Cols[viDestCol].RowSpan then  // ���һԴ�У����һԴ�д������Ŀ�����п�ȼ���1
        FRows[viDestRow].Cols[viDestCol].ColSpan := FRows[viDestRow].Cols[viDestCol].ColSpan - 1;
    end
    else
    if FRows[vRow].Cols[ACol].ColSpan > 0 then  // �ϲ�Ŀ��
    begin

    end;

    FRows[vRow].Delete(ACol);
  end;

  FColWidths.Delete(ACol);

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Self.SizeChanged := True;
  FLastChangeFormated := False;
  Result := True;
end;

function THCTableItem.DeleteCurCol: Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;

  if FColWidths.Count > 1 then
    Result := DeleteCol(FSelectCellRang.StartCol);
end;

function THCTableItem.DeleteCurRow: Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;

  if FRows.Count > 1 then
    Result := DeleteRow(FSelectCellRang.StartRow);
end;

function THCTableItem.DeleteRow(const ARow: Integer): Boolean;
var
  i, vCol: Integer;
  viDestRow, viDestCol: Integer;
begin
  Result := False;

  if not RowCanDelete(ARow) then Exit;

  for vCol := 0 to FColWidths.Count - 1 do
  begin
    if FRows[ARow].Cols[vCol].RowSpan < 0 then  // �ϲ�Դ
    begin
      GetDestCell(ARow, vCol, viDestRow, viDestCol);  // Ŀ���С���
      for i := ARow + 1 to viDestRow + FRows[viDestRow].Cols[viDestCol].RowSpan do  // ��ǰ������ĺϲ�Դ����Ŀ���1
        FRows[i].Cols[vCol].RowSpan := FRows[i].Cols[vCol].RowSpan + 1;

      if vCol = viDestCol + FRows[viDestRow].Cols[viDestCol].ColSpan then  // ���һԴ�У����һԴ�д�����󣬴���Ŀ�����п�ȼ���1
        FRows[viDestRow].Cols[viDestCol].RowSpan := FRows[viDestRow].Cols[viDestCol].RowSpan - 1;
    end
    else
    if FRows[ARow].Cols[vCol].ColSpan > 0 then  // �ϲ�Ŀ��
    begin

    end;
  end;

  FRows.Delete(ARow);

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Self.SizeChanged := True;
  FLastChangeFormated := False;
  Result := True;
end;

function THCTableItem.DeleteSelected: Boolean;
var
  vR, vC: Integer;
begin
  Result := inherited DeleteSelected;

  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    if FSelectCellRang.EndRow >= 0 then  // ��ѡ������У�˵��ѡ�в���ͬһ��Ԫ��
    begin
      Result := True;
      for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          if Cells[vR, vC].CellData <> nil then
            Cells[vR, vC].CellData.DeleteSelected;
        end;
      end;
    end
    else  // ��ͬһ��Ԫ��
      Result := GetEditCell.CellData.DeleteSelected;
  end;
end;

destructor THCTableItem.Destroy;
begin
  FSelectCellRang.Free;
  FPageBreaks.Free;
  FRows.Clear;
  FRows.Free;
  FColWidths.Free;
  //Dispose(FResizeInfo);
  //Dispose(FCaretInfo);
  inherited Destroy;
end;

procedure THCTableItem.DisSelect;
begin
  inherited DisSelect;

  DisSelectSelectedCell;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;

  FSelecting := False;
  FDraging := False;
  FOutSelectInto := False;
end;

procedure THCTableItem.DisSelectSelectedCell(const ARow: Integer = -1;
  const ACol: Integer = -1);
var
  vRow, vCol: Integer;
  vCellData: THCTableCellData;
begin
  if FSelectCellRang.StartRow >= 0 then
  begin
    // ������ʼ��ȷ����ǰ��Ԫ���ִ��DisSelect ��201805172309����
    if (FSelectCellRang.StartRow = ARow) and (FSelectCellRang.StartCol = ACol) then

    else
    begin
      vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
      if vCellData <> nil then
      begin
        vCellData.DisSelect;
        vCellData.InitializeField;
      end;
    end;

    for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
    begin
      for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
      begin
        if (vRow = ARow) and (vCol = ACol) then

        else
        begin
          vCellData := FRows[vRow].Cols[vCol].CellData;
          if vCellData <> nil then
          begin
            vCellData.DisSelect;
            vCellData.InitializeField;
          end;
        end;
      end;
    end;
  end;
end;

function THCTableItem.DoCellDataGetRootData: THCCustomData;
begin
  Result := OwnerData.GetRootData;
end;

function THCTableItem.DoSelfUndoNew: THCUndo;
var
  vCellUndoData: THCCellUndoData;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    Result := THCDataUndo.Create;
    vCellUndoData := THCCellUndoData.Create;
    vCellUndoData.Row := FSelectCellRang.StartRow;
    vCellUndoData.Col := FSelectCellRang.StartCol;
    Result.Data := vCellUndoData;
  end
  else
    Result := inherited DoSelfUndoNew;
end;

procedure THCTableItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vR, vC,
  vCellScreenTop,
  vCellScreenBottom,
  vCellDataDrawTop,  // ��ǰ��Ԫ�����ݻ��ƶ���λ��
  vCellDataDrawBottom,  // ��ǰ��Ԫ�����ݻ��Ƶײ�λ��
  vCellDrawLeft,  // ��Ԫ�����ʱ�����ʼλ��(��߿��ұ�)
  //vFristDItemNo,
  //vLastDItemNo,
  vBorderLeft,
  vBorderTop,
  vBorderRight,
  vBorderBottom,
  vShouLian,
  vDestRow, vDestCol, vDestRow2, vDestCol2, vSrcRowBorderTop,
  vDestCellDataDrawTop, vFirstDrawRow  // ���λ��Ƶĵ�һ��
    : Integer;
  //vDrawBord: Boolean;  // ��ĳһ���ڵ�ǰҳ����ʾ������������û��һ����DItem�ܻ��ƣ���ʱ(1)������ͨ������ȴ����Ҫ���Ʊ߿�
  vDrawBorder,
  vDrawCellData  // �˵�Ԫ�������Ƿ���Ҫ���ƣ��ϲ�Դ��ֻ�ںϲ�Ŀ��ʱ����һ�Σ������λ���
    : Boolean;
  vCellData: THCTableCellData;

  {$REGION ' CheckRowBorderShouLian �ҵ�ǰ�и��з�ҳʱ������λ��'}
  procedure CheckRowBorderShouLian(const ARow: Integer);
  var
    vC, i, vRowDataDrawTop, vDestCellDataDrawTop, vBreakBottom: Integer;
    vRect: TRect;
  begin
    if vShouLian = 0 then  // û�м������ǰ���п�ҳ������������ѿ�ҳʱ����λ��
    begin
      vRowDataDrawTop := ADrawRect.Top + FBorderWidth - 1;  // ��Ϊ�߿���ADrawRect.TopҲռ1���أ�����Ҫ����
      for i := 0 to ARow - 1 do
        vRowDataDrawTop := vRowDataDrawTop + FRows[i].FmtOffset + FRows[i].Height + FBorderWidth;

      if (FRows[ARow].FmtOffset > 0)  // ��ҳ������������
        and (ARow <> vFirstDrawRow)  // ���ǵ�һ�λ����������Ƶķ�ҳ��
      then  // ����һ�����Ϊ����
      begin
        vShouLian := vRowDataDrawTop - FBorderWidth + 1;  // ��һ�еײ��߿�λ��
        Exit;
      end;

      // ��ҳ��Data������ʼλ�ã���һ�λ����������Ʒ�ҳ��ʱҪ����ƫ�ƣ���������(����һ�н�β��ͬ)��Ϊ����λ��(��ǰ����Exit��)
      vRowDataDrawTop := vRowDataDrawTop + FRows[ARow].FmtOffset + FCellVPadding;

      vBreakBottom := 0;
      for vC := 0 to FRows[ARow].ColCount - 1 do  // ����ͬ�и��У���ȡ�ض�λ��(��Ϊ������CheckFormatPage�Ѿ���÷�ҳλ�ã����Դ˴�ֻҪһ����Ԫ���ҳλ��ͬʱ���õ�ǰ�����е�Ԫ���ҳλ��)
      begin
        vDestCellDataDrawTop := vRowDataDrawTop;//vCellDataDrawTop;
        GetMergeDest(ARow, vC, vDestRow2, vDestCol2);  // ��ȡ��Ŀ�굥Ԫ�������к�

        if vC <> vDestCol2 + FRows[vDestRow2].Cols[vDestCol2].ColSpan then  // ֻ�ڵ�ǰҳ��ҳλ�õĺϲ����Դ����һ��
          Continue;

        vCellData := FRows[vDestRow2].Cols[vDestCol2].CellData;  // �ȸ�ֵĿ�굥Ԫ��Data
        if vDestRow2 <> ARow then  // ��Դ�У���ȡĿ��λ�ã���ȡ���������������λ��
        begin
          vDestCellDataDrawTop := vDestCellDataDrawTop - SrcCellDataDrawTopDistanceToDest(ARow, vDestRow2);
//          vDestCellDataDrawTop := vDestCellDataDrawTop{ - FCellVPadding������ļ�Լ��} - FBorderWidth - FRows[ARow].FmtOffset;  // �ȼ�����ǰ�п�ҳƫ��
//
//          while vDestRow2 < ARow do  // ��������Ŀ�굥Ԫ���CellDataDrawTop
//          begin
//            vDestCellDataDrawTop := vDestCellDataDrawTop - FBorderWidth - FRows[vDestRow2].Height - FRows[vDestRow2].FmtOffset;
//            Inc(vDestRow2);
//          end;
//
//          vDestCellDataDrawTop := vDestCellDataDrawTop - FRows[ARow].Height{ + FCellVPadding������ļ�Լ��}
        end;

        for i := 0 to vCellData.DrawItems.Count - 1 do
        begin
          if vCellData.DrawItems[i].LineFirst then
          begin
            vRect := vCellData.DrawItems[i].Rect;
            //if DrawiInLastLine(i) then  // ��Ԫ�������һ�����ݲ���FCellVPadding
            vRect.Bottom := vRect.Bottom + FCellVPadding; // ÿһ�п�����Ҫ�ضϵģ��ض�ʱ����Ҫ�ܷ���FCellVPadding
            if vDestCellDataDrawTop + vRect.Bottom > ADataDrawBottom then  // ��DrawItem������ǰҳ��
            begin
              if i > 0 then  // ��ҳ��Draw���ǵ�һ��
              begin
                if ADataDrawBottom - vDestCellDataDrawTop - vCellData.DrawItems[i - 1].Rect.Bottom > FCellVPadding then
                  vShouLian := Max(vShouLian, vDestCellDataDrawTop + vCellData.DrawItems[i - 1].Rect.Bottom + FCellVPadding)
                else
                  vShouLian := Max(vShouLian, vDestCellDataDrawTop + vCellData.DrawItems[i - 1].Rect.Bottom);  // ��һ����������Ϊ�ض�λ��
              end
              else  // ��һ�о��ڵ�ǰҳ�Ų���
                vShouLian := Max(vShouLian, vDestCellDataDrawTop - FCellVPadding - FBorderWidth + 1);

              Break;
            end
            else  // ��DrawItemû�г�����ǰҳ
              vBreakBottom := Max(vBreakBottom, vDestCellDataDrawTop + vRect.Bottom);  // ��¼Ϊ�ɷ��µ����һ������(�еĵ�Ԫ���ڵ�ǰҳ��ȫ����ʾ��������ҳ)
          end;
        end;
      end;
      vShouLian := Max(vShouLian, vBreakBottom);
    end;
  end;
  {$ENDREGION}

  {$REGION ' DoDrawPageBreakMark ���Ʒ�ҳ��ʶ�� '}
  procedure DoDrawPageBreakMark(const APageEnd: Boolean);
  begin
    ACanvas.Pen.Color := clGray;
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Width := 1;

    if APageEnd then  // ��ҳ��(ҳ����λ��)
    begin
      ACanvas.MoveTo(vBorderRight + 5, vBorderBottom - 1);  // vBorderBottom
      ACanvas.LineTo(vBorderRight + 20, vBorderBottom - 1);

      ACanvas.Pen.Style := psSolid;
      ACanvas.MoveTo(vBorderRight + 19, vBorderBottom - 3);
      ACanvas.LineTo(vBorderRight + 19, vBorderBottom - 10);
      ACanvas.LineTo(vBorderRight + 5, vBorderBottom - 10);
      ACanvas.LineTo(vBorderRight + 5, vBorderBottom - 2);
    end
    else  // ��ҳ��(ҳ��ʼλ��)
    begin
      ACanvas.MoveTo(vBorderRight + 5, ADataDrawTop + 1);  // vBorderTop
      ACanvas.LineTo(vBorderRight + 20, ADataDrawTop + 1);

      ACanvas.Pen.Style := psSolid;
      ACanvas.MoveTo(vBorderRight + 19, ADataDrawTop + 3);
      ACanvas.LineTo(vBorderRight + 19, ADataDrawTop + 10);
      ACanvas.LineTo(vBorderRight + 5, ADataDrawTop + 10);
      ACanvas.LineTo(vBorderRight + 5, ADataDrawTop + 2);
    end;

    ACanvas.Pen.Color := clBlack;
  end;
  {$ENDREGION}

begin
  ACanvas.Pen.Width := FBorderWidth;
  // ��Ԫ��
  vFirstDrawRow := -1;
  vCellDataDrawTop := ADrawRect.Top + FBorderWidth - 1;  // ��1�����ݻ�����ʼλ�ã���Ϊ�߿���ADrawRect.TopҲռ1���أ�����Ҫ����
  for vR := 0 to FRows.Count - 1 do
  begin
    // ���ڵ�ǰ��Ļ��Χ�ڵĲ�����(1)
    vCellDataDrawTop := vCellDataDrawTop + FRows[vR].FmtOffset + FCellVPadding;
    if vCellDataDrawTop > ADataScreenBottom then  // �����ݶ������ڿ���ʾ������ʾ������������
      Break;
    vCellDataDrawBottom := vCellDataDrawTop - FCellVPadding + FRows[vR].Height - FCellVPadding;

    if vCellDataDrawBottom < ADataScreenTop then  // ��ǰ�еײ�С�ڿ���ʾ������û��ʾ����������
    begin
      vCellDataDrawTop := vCellDataDrawBottom + FCellVPadding + FBorderWidth;  // ׼���ж���һ���Ƿ��ǿ���ʾ��һ��
      Continue;
    end;
    if vFirstDrawRow < 0 then  // ��¼���λ��Ƶĵ�һ��
      vFirstDrawRow := vR;

    vCellDrawLeft := ADrawRect.Left + FBorderWidth - 1;

    // ѭ���������и���Ԫ�����ݺͱ߿�
    vShouLian := 0;
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      if FRows[vR].Cols[vC].ColSpan < 0 then  // �ϲ���Դ
      begin
        vCellDrawLeft := vCellDrawLeft + FColWidths[vC] + FBorderWidth;
        Continue;  // ��ͨ��Ԫ���ϲ�Ŀ�굥Ԫ��������ݣ�������Ŀ�굥Ԫ����
      end;

      vDrawCellData := True;  // ����Ŀ�����п�ҳ����Ŀ���к����ж��кϲ�������ʱ��ֻ�ڿ�ҳ�����һ��Ŀ���е�����
      if FRows[vR].Cols[vC].RowSpan < 0 then  // 20170208001 �Ǻϲ���Դ��Ԫ��(���������ų�����Դ����������ֻ��Ŀ�굥Ԫ�����·��ĵ�Ԫ��)
      begin
        if vR <> vFirstDrawRow then  // ���ǿ�ҳ���һ�λ��Ƶ���
          vDrawCellData := False;  // Ŀ�굥Ԫ���Ѿ���ҳ���������ݣ������ظ������ˣ�������к�ĵ�һ��Ҫ����
      end;

      //vFristDItemNo := -1;
      //vLastDItemNo := -1;
      vDestCellDataDrawTop := vCellDataDrawTop;
      GetMergeDest(vR, vC, vDestRow, vDestCol);  // ��ȡ��Ŀ�굥Ԫ�������к�
      if vDestRow <> vR then
        vDestCellDataDrawTop := vDestCellDataDrawTop - SrcCellDataDrawTopDistanceToDest(vR, vDestRow);
//      begin
//        vDestCellDataDrawTop := vDestCellDataDrawTop{ - FCellVPadding������ļ�Լ��} - FBorderWidth - FRows[vR].FmtOffset;
//
//        vDestRow2 := vR - 1;
//        while vDestRow2 > vDestRow do
//        begin
//          vDestCellDataDrawTop := vDestCellDataDrawTop - FBorderWidth - FRows[vDestRow2].Height - FRows[vDestRow2].FmtOffset;
//          Dec(vDestRow2);
//        end;
//
//        vDestCellDataDrawTop := vDestCellDataDrawTop - FRows[vDestRow].Height{ + FCellVPadding�������Լ��};
//      end;

      {vDestRow2 := vDestRow;
      while vDestRow2 < vR do  // �õ�Ŀ�굥Ԫ��CellDataDrawTop��ֵ
      begin
        if vDestRow2 <> vDestRow then
          vDestCellDataDrawTop := vDestCellDataDrawTop - FRows[vDestRow2].Height - FRows[vDestRow2].FmtOffset - FBorderWidth
        else
          vDestCellDataDrawTop := vDestCellDataDrawTop - FRows[vDestRow2].Height - FBorderWidth;

        Inc(vDestRow2);
      end;
      if vDestRow <> vR then
        Dec(vDestCellDataDrawTop, FRows[vR].FmtOffset);}

      {$REGION ' ���Ƶ�Ԫ������ '}
      if vDrawCellData then
      begin
        vCellScreenBottom := Math.Min(ADataScreenBottom,  // ���������������¶�
          vCellDataDrawTop
          + Max(FRows[vR].Height, FRows[vDestRow].Cols[vDestCol].Height) - FCellVPadding  // �иߺ��кϲ��ĵ�Ԫ���������
          );

        //Assert(vCellScreenBottom - vMergeCellDataDrawTop >= FRows[vR].Height, '�ƻ�ʹ��Continue����ȷ�ϻ���������');
        vCellData := FRows[vDestRow].Cols[vDestCol].CellData;  // Ŀ��CellData��20170208003 ����Ƶ�if vDrawData������20170208002����Ҫ��
        vCellScreenTop := Math.Max(ADataScreenTop, vCellDataDrawTop - FCellVPadding);  // �������϶�
        if vCellScreenTop - vDestCellDataDrawTop < vCellData.Height then  // ����ʾ����ʼλ��С�����ݸ߶�(��>=ʱ˵�����ݸ߶�С���и�ʱ�������Ѿ���ȫ��������)
        begin
          // ����ɫ
          if (Self.IsSelectComplate or vCellData.CellSelectedAll) and (not APaintInfo.Print) then  // ���ȫѡ�л�Ԫ��ȫѡ��
            ACanvas.Brush.Color := OwnerData.Style.SelColor
          else
          begin
            if FRows[vDestRow].Cols[vDestCol].BackgroundColor <> HCTransparentColor then
              ACanvas.Brush.Color := FRows[vDestRow].Cols[vDestCol].BackgroundColor
            else
              ACanvas.Brush.Style := bsClear;
          end;

          ACanvas.FillRect(Rect(vCellDrawLeft - FBorderWidth + 1, vCellScreenTop,  // + FRows[vR].Height,
            vCellDrawLeft + FRows[vR].Cols[vC].Width + FBorderWidth, vCellScreenBottom));

          {$IFDEF SHOWDRAWITEMNO}
          ACanvas.Font.Color := clGray;
          ACanvas.Font.Style := [];
          ACanvas.Font.Size := 8;
          ACanvas.TextOut(vCellDrawLeft + 1, vDestCellDataDrawTop, IntToStr(vR) + '/' + IntToStr(vC));
          {$ENDIF}

          // ��ȡ����ʾ�������ʼ������DrawItem
          //vCellData.GetDataDrawItemRang(Math.Max(vCellScreenTop - vDestCellDataDrawTop, 0),
          //  vCellScreenBottom - vDestCellDataDrawTop, vFristDItemNo, vLastDItemNo);
          //if vFristDItemNo >= 0 then
          if vCellScreenBottom - vCellScreenTop > FCellVPadding then  // �п���ʾ��DrawItem
          begin
            FRows[vDestRow].Cols[vDestCol].PaintData(
              vCellDrawLeft + FCellHPadding + 1, vDestCellDataDrawTop + 1,
              ADataDrawBottom, ADataScreenTop, ADataScreenBottom,
              0, ACanvas, APaintInfo);
          end;
        end;
      end;
      {$ENDREGION}

      {$REGION ' ���Ƹ���Ԫ��߿��� '}
      if FBorderVisible or (not APaintInfo.Print) then
      begin
        vDrawBorder := True;
        // Ŀ�굥Ԫ����ϱ߿����λ�� vDestCellDataDrawTop����ռ����1����
        // FBorderWidth + FCellVPadding = vDestCellDataDrawTop��vDestCellDataDrawTop��FCellVapdding�ص���1����
        vBorderTop := vDestCellDataDrawTop - FCellVPadding + 1 - FBorderWidth;
        vBorderBottom := vBorderTop  // ����߿����¶�
          + Max(FRows[vR].Height, Cells[vDestRow, vDestCol].Height)  // ���ڿ����Ǻϲ�Ŀ�굥Ԫ�������õ�Ԫ��ߺ��и���ߵ�
          + FBorderWidth;

        // Ŀ�굥Ԫ��ײ��߿򳬹�ҳ�ײ�����������λ��
        if vBorderBottom > ADataScreenBottom then  // Ŀ��ײ��߿� > ҳ�������Եײ����ײ���ʾ��ȫ��ײ��絽��һҳ��
        begin
          if Cells[vR, vC].RowSpan > 0 then  // �Ǻϲ�Ŀ�굥Ԫ��
          begin
            vSrcRowBorderTop := vBorderTop;
            vDestRow2 := vR;  // ���ñ���
            while vDestRow2 <= FRows.Count - 1 do  // ����ʾ�ײ��߿��Դ
            begin
              vSrcRowBorderTop := vSrcRowBorderTop + FRows[vDestRow2].FmtOffset + FRows[vDestRow2].Height + FBorderWidth;
              if vSrcRowBorderTop > ADataScreenBottom then  // �˺ϲ�Դ��Ԫ�����ڵ��еײ��߿���ʾ��������
              begin
                if vSrcRowBorderTop > ADataDrawBottom then  // ��ҳ
                begin
                  CheckRowBorderShouLian(vDestRow2);  // �ӵ�ǰ��������
                  vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
                end;

                Break;
              end;

              Inc(vDestRow2);
            end;
          end
          else
          if Cells[vR, vC].RowSpan < 0 then  // �ϲ�Դ��Ԫ�����ڿ�ʼ����20170208001�жϣ����Դ˴��϶��Ǻϲ�Ŀ�����·��ĵ�Ԫ��
          begin
            if vR <> vFirstDrawRow then  // ���ǵ�һ�λ��Ƶ��У�˵����Դ�Լ�������Ŀ��ĵײ��߿���
              vDrawBorder := False
            else  // ��ҳ���һ�λ���
            begin
              { �ƶ�����ǰ����ʼλ�� }
              vSrcRowBorderTop := vBorderTop;  // ���ñ�����vBorderTopֵ��Ŀ�굥Ԫ����ϱ߿�
              for vDestRow2 := vDestRow to vR - 1 do
                vSrcRowBorderTop := vSrcRowBorderTop + FRows[vDestRow2].Height + FBorderWidth;

              // ���ǿ�ҳ��Ŀ�굥Ԫ�����ڴ�ҳԴ�ĵ�һ������Ҫ����Ŀ���ڴ�ҳ�ı߿�
              vDestRow2 := vR;  // ���ñ���
              while vDestRow2 <= FRows.Count - 1 do  // ����ʾ�ײ��߿��Դ
              begin
                vSrcRowBorderTop := vSrcRowBorderTop + FRows[vDestRow2].Height + FBorderWidth;
                if vSrcRowBorderTop > ADataScreenBottom then  // �˺ϲ�Դ��Ԫ�����ڵ��еײ��߿���ʾ��������
                begin
                  if vSrcRowBorderTop > ADataDrawBottom then  // ��ҳ
                  begin
                    CheckRowBorderShouLian(vDestRow2);  // �ӵ�ǰ��������
                    vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
                  end;

                  Break;
                end;

                Inc(vDestRow2);
              end;
            end;
          end
          else  // ��ͨ��Ԫ��(���Ǻϲ�Ŀ��Ҳ���Ǻϲ�Դ)��ҳ����������
          begin
            CheckRowBorderShouLian(vR);
            vBorderBottom := vShouLian;
          end;
        end;

        {if Cells[vR, vC].RowSpan < 0 then  // �ϲ�Դ��Ԫ�����ڿ�ʼ����20170208001�жϣ����Դ˴��϶��Ǻϲ�Ŀ�����·��ĵ�Ԫ��
        begin
          if vR <> vFirstDrawRow then  // ���ǵ�һ�λ��Ƶ��У�˵����Դ�Լ�������Ŀ��ĵײ��߿���
            vDrawBorder := False
          else
          begin
            // �ƶ�����ǰ����ʼλ��
            vSrcRowBorderTop := vBorderTop;  // ���ñ�����vBorderTopֵ��Ŀ�굥Ԫ����ϱ߿�
            for vDestRow2 := vDestRow to vR - 1 do
              vSrcRowBorderTop := vSrcRowBorderTop + FRows[vDestRow2].Height + FBorderWidth;

            // ���ǿ�ҳ��Ŀ�굥Ԫ�����ڴ�ҳԴ�ĵ�һ������Ҫ����Ŀ���ڴ�ҳ�ı߿�
            vDestRow2 := vR;  // ���ñ���
            while vDestRow2 <= FRows.Count - 1 do  // ����ʾ�ײ��߿��Դ
            begin
              vSrcRowBorderTop := vSrcRowBorderTop + FRows[vDestRow2].Height + FBorderWidth;
              if vSrcRowBorderTop > ADataScreenBottom then  // �˺ϲ�Դ��Ԫ�����ڵ��еײ��߿���ʾ��������
              begin
                if vSrcRowBorderTop > ADataDrawBottom then  // ��ҳ
                begin
                  CheckRowBorderShouLian(vDestRow2);  // �ӵ�ǰ��������
                  vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
                end;

                Break;
              end;

              Inc(vDestRow2);
            end;
          end;
        end;}

        if vDrawBorder then  // �߿������ʾ
        begin
          ACanvas.Pen.Width := FBorderWidth;

          if FBorderVisible then  // δ���ر߿�
          begin
            ACanvas.Pen.Color := clBlack;
            ACanvas.Pen.Style := psSolid;
          end
          else
          if not APaintInfo.Print then
          begin
            ACanvas.Pen.Color := clActiveBorder;
            ACanvas.Pen.Style := psDot;
          end;

          vBorderLeft := vCellDrawLeft - FBorderWidth + 1;
          vBorderRight := vBorderLeft + FColWidths[vC] + FBorderWidth;

          vDestCol2 := FRows[vDestRow].Cols[vDestCol].ColSpan;  // ���ñ���
          while vDestCol2 > 0 do
          begin
            vBorderRight := vBorderRight +  FBorderWidth + FColWidths[vDestCol + vDestCol2];
            Dec(vDestCol2);
          end;

          if vBorderTop < ADataScreenTop then  // ���ǰ����ʾ��ȫ����ǰ�п�ҳ��ʱ����һҳ����
            vBorderTop := ADataScreenTop;

          if (vBorderTop > 0) and (cbsTop in FRows[vR].Cols[vC].BorderSides) then  // �ϱ߿����ʾ
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);   // ����
            ACanvas.LineTo(vBorderRight, vBorderTop);  // ����
          end;

          if cbsRight in FRows[vR].Cols[vC].BorderSides then  // �ұ߿�
          begin
            ACanvas.MoveTo(vBorderRight, vBorderTop);  // ����
            ACanvas.LineTo(vBorderRight, vBorderBottom);  // ����
          end;

          if (vBorderBottom <= ADataScreenBottom) and (cbsBottom in FRows[vR].Cols[vC].BorderSides) then  // �±߿�
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderBottom);  // ����
            ACanvas.LineTo(vBorderRight + 1, vBorderBottom);  // ����
          end;

          if cbsLeft in FRows[vR].Cols[vC].BorderSides then  // ��߿�
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);
            ACanvas.LineTo(vBorderLeft, vBorderBottom);
          end;

          if cbsLTRB in FRows[vR].Cols[vC].BorderSides then  // �������¶Խ���
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);
            ACanvas.LineTo(vBorderRight, vBorderBottom);
          end;

          if cbsRTLB in FRows[vR].Cols[vC].BorderSides then  // �������¶Խ���
          begin
            ACanvas.MoveTo(vBorderRight, vBorderTop);
            ACanvas.LineTo(vBorderLeft, vBorderBottom);
          end;

          // "���һ��"������Ʒ�ҳ��ʶ
          vDestCol2 := vC + FRows[vR].Cols[vC].ColSpan;
          if (not APaintInfo.Print) and (vDestCol2 = FColWidths.Count - 1) then  // �Ǵ�ӡ�����һ�л��Ʒ�ҳ��ʶ
          begin
            if vCellDataDrawTop + FRows[vR].Height - FCellVPadding > ADataDrawBottom then  // ���п�ҳ����ҳ��(��ҳ��β)
              DoDrawPageBreakMark(True)
            else
            if (vR < Self.RowCount - 1)
              and (vBorderBottom + FRows[vR + 1].FmtOffset + FRows[vR + 1].Height > ADataDrawBottom)
            then  // ��һ�п�ҳ
            begin
              if FRows[vR + 1].FmtOffset > 0 then  // ��һ�����������ˣ���ҳ��(��ҳ��β)
                DoDrawPageBreakMark(True)
              else
              if vBorderBottom = ADataDrawBottom then  //* ��һ����ʼ�ڱ�ҳ��β��
                DoDrawPageBreakMark(True);             //* ��ʱ��һ�в��ڱ�ҳ��ʾ����FmtOffset��������0��
            end;                                       //* ������ﲻ����ѭ����һ��ʱ�ײ����ڵ�ǰҳֱ������ѭ��ʧȥ���ƻ���

            if (vFirstDrawRow <> 0)  // ��ʼ�в��ǵ�һ��
              and (vR = vFirstDrawRow)  // ��ʼ�л���
              and (ADrawRect.Top < ADataDrawTop)  // ��һ������һҳ
            then  // ��ҳ��(��ҳ��ʼ)
              DoDrawPageBreakMark(False);
          end;
        end;
      end;
      {$ENDREGION}

      vCellDrawLeft := vCellDrawLeft + FColWidths[vC] + FBorderWidth;  // ͬ����һ�е���ʼLeftλ��
    end;

    vCellDataDrawTop := vCellDataDrawBottom + FCellVPadding+ FBorderWidth;  // ��һ�е�Topλ��
  end;

  {$REGION ' �����϶��� '}
  if Resizing and (FResizeInfo.TableSite = tsBorderRight) then  // ��ֱ
  begin
    ACanvas.Pen.Color := Self.FBorderColor;
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Width := 1;
    ACanvas.MoveTo(ADrawRect.Left + FResizeInfo.DestX, Max(ADataDrawTop, ADrawRect.Top));
    ACanvas.LineTo(ADrawRect.Left + FResizeInfo.DestX, Min(ADataDrawBottom,
      Min(ADrawRect.Bottom, vBorderBottom)));
  end
  else
  if Resizing and (FResizeInfo.TableSite = tsBorderBottom) then  // ˮƽ
  begin
    ACanvas.Pen.Color := Self.FBorderColor;
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Width := 1;
    ACanvas.MoveTo(ADrawRect.Left, ADrawRect.Top + FResizeInfo.DestY);
    ACanvas.LineTo(ADrawRect.Right, ADrawRect.Top + FResizeInfo.DestY);
  end;
  {$ENDREGION}
end;

procedure THCTableItem.DoSelfRedo(const ARedo: THCUndo);
var
  vRedoCellUndoData: THCCellUndoData;
  vColSizeUndoData: THCColSizeUndoData;
  vRowSizeUndoData: THCRowSizeUndoData;
  vMirrorUndoData: THCMirrorUndoData;
  vStream: TMemoryStream;
  vStyleNo: Integer;
begin
  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;

  if ARedo.Data is THCCellUndoData then
  begin
    vRedoCellUndoData := ARedo.Data as THCCellUndoData;
    FSelectCellRang.StartRow := vRedoCellUndoData.Row;
    FSelectCellRang.StartCol := vRedoCellUndoData.Col;
    Cells[vRedoCellUndoData.Row, vRedoCellUndoData.Col].CellData.Redo(ARedo);
  end
  else
  if ARedo.Data is THCColSizeUndoData then
  begin
    vColSizeUndoData := ARedo.Data as THCColSizeUndoData;
    if vColSizeUndoData.Col < FColWidths.Count - 1 then
    begin
      FColWidths[vColSizeUndoData.Col + 1] := FColWidths[vColSizeUndoData.Col + 1] +
        FColWidths[vColSizeUndoData.Col] - vColSizeUndoData.NewWidth;
    end;
    FColWidths[vColSizeUndoData.Col] := vColSizeUndoData.NewWidth;
  end
  else
  if ARedo.Data is THCRowSizeUndoData then
  begin
    vRowSizeUndoData := ARedo.Data as THCRowSizeUndoData;
    FRows[vRowSizeUndoData.Row].Height := vRowSizeUndoData.NewHeight;
  end
  else
  if ARedo.Data is THCMirrorUndoData then
  begin
    vStream := TMemoryStream.Create;
    try
      Self.SaveToStream(vStream);  // ��¼�ָ�ǰ״̬

      vMirrorUndoData := ARedo.Data as THCMirrorUndoData;
      vMirrorUndoData.Stream.Position := 0;
      vMirrorUndoData.Stream.ReadBuffer(vStyleNo, SizeOf(vStyleNo));
      Self.LoadFromStream(vMirrorUndoData.Stream, OwnerData.Style, HC_FileVersionInt);

      vMirrorUndoData.Stream.Clear;
      vMirrorUndoData.Stream.CopyFrom(vStream, 0);  // ����ָ�ǰ״̬
    finally
      vStream.Free;
    end;
  end
  else
    inherited DoSelfRedo(ARedo);
end;

procedure THCTableItem.DoRowAdd(const ARow: THCTableRow);
var
  i: Integer;
  vCellData: THCTableCellData;
begin
  for i := 0 to ARow.ColCount - 1 do
  begin
    vCellData := ARow.Cols[i].CellData;
    if vCellData <> nil then
      InitializeCellData(vCellData);
  end;
end;

procedure THCTableItem.DoSelfUndo(const AUndo: THCUndo);
var
  vCellUndoData: THCCellUndoData;
  vColSizeUndoData: THCColSizeUndoData;
  vRowSizeUndoData: THCRowSizeUndoData;
  vMirrorUndoData: THCMirrorUndoData;
  vStyleNo: Integer;
  vStream: TMemoryStream;
begin
  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;

  if AUndo.Data is THCCellUndoData then
  begin
    vCellUndoData := AUndo.Data as THCCellUndoData;
    FSelectCellRang.StartRow := vCellUndoData.Row;
    FSelectCellRang.StartCol := vCellUndoData.Col;

    Cells[vCellUndoData.Row, vCellUndoData.Col].CellData.Undo(AUndo);
  end
  else
  if AUndo.Data is THCColSizeUndoData then
  begin
    vColSizeUndoData := AUndo.Data as THCColSizeUndoData;
    if vColSizeUndoData.Col < FColWidths.Count - 1 then
    begin
      FColWidths[vColSizeUndoData.Col + 1] := FColWidths[vColSizeUndoData.Col + 1] +
        FColWidths[vColSizeUndoData.Col] - vColSizeUndoData.OldWidth;
    end;
    FColWidths[vColSizeUndoData.Col] := vColSizeUndoData.OldWidth;
  end
  else
  if AUndo.Data is THCRowSizeUndoData then
  begin
    vRowSizeUndoData := AUndo.Data as THCRowSizeUndoData;
    FRows[vRowSizeUndoData.Row].Height := vRowSizeUndoData.OldHeight;
  end
  else
  if AUndo.Data is THCMirrorUndoData then
  begin
    vStream := TMemoryStream.Create;
    try
      Self.SaveToStream(vStream);  // ��¼����ǰ״̬

      // �ָ�ԭ��
      vMirrorUndoData := AUndo.Data as THCMirrorUndoData;
      vMirrorUndoData.Stream.Position := 0;
      vMirrorUndoData.Stream.ReadBuffer(vStyleNo, SizeOf(vStyleNo));
      Self.LoadFromStream(vMirrorUndoData.Stream, OwnerData.Style, HC_FileVersionInt);

      vMirrorUndoData.Stream.Clear;
      vMirrorUndoData.Stream.CopyFrom(vStream, 0);  // ���泷��ǰ״̬
    finally
      vStream.Free;
    end;
  end
  else
    inherited DoSelfUndo(AUndo);
end;

procedure THCTableItem.DoSelfUndoDestroy(const AUndo: THCUndo);
begin
  if AUndo.Data is THCCellUndoData then
    (AUndo.Data as THCCellUndoData).Free;

  inherited DoSelfUndoDestroy(AUndo);
end;

procedure THCTableItem.KeyDown(var Key: Word; Shift: TShiftState);

  function IsDirectionKey(const AKey: Word): Boolean;
  begin
    Result := AKey in [VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN];
  end;

var
  vEditCell: THCTableCell;

  function DoCrossCellKey(const AKey: Word): Boolean;
  var
    i, vRow, vCol: Integer;
  begin
    Result := False;

    vRow := -1;
    vCol := -1;

    {$REGION 'VK_LEFT'}
    if AKey = VK_LEFT then
    begin
      if vEditCell.CellData.SelectFirstItemOffsetBefor then
      begin
        // ����൥Ԫ��
        for i := FSelectCellRang.StartCol - 1 downto 0 do
        begin
          if Cells[FSelectCellRang.StartRow, i].ColSpan >= 0 then
          begin
            if Cells[FSelectCellRang.StartRow, i].RowSpan < 0 then
              FSelectCellRang.StartRow := FSelectCellRang.StartRow + Cells[FSelectCellRang.StartRow, i].RowSpan;

            vCol := i;
            Break;
          end;
        end;

        if vCol >= 0 then
        begin
          FSelectCellRang.StartCol := vCol;
          Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectLastItemAfterWithCaret;
          Result := True;
        end;
      end;
    end
    {$ENDREGION}
    else
    {$REGION 'VK_RIGHT'}
    if AKey = VK_RIGHT then
    begin
      if vEditCell.CellData.SelectLastItemOffsetAfter then
      begin
        // ���Ҳ൥Ԫ��
        for i := FSelectCellRang.StartCol + 1 to FColWidths.Count - 1 do
        begin
          if Cells[FSelectCellRang.StartRow, i].ColSpan >= 0 then
          begin
            if Cells[FSelectCellRang.StartRow, i].RowSpan < 0 then
              FSelectCellRang.StartRow := FSelectCellRang.StartRow + Cells[FSelectCellRang.StartRow, i].RowSpan;

            vCol := i;
            Break;
          end;
        end;

        if vCol >= 0 then
        begin
          FSelectCellRang.StartCol := vCol;
          Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectFirstItemBeforWithCaret;
          Result := True;
        end;
      end
    end
    {$ENDREGION}
    else
    {$REGION 'VK_UP'}
    if AKey = VK_UP then
    begin
      if (vEditCell.CellData.SelectFirstLine) and (FSelectCellRang.StartRow > 0) then  // ����һ�е�Ԫ��
      begin
        GetDestCell(FSelectCellRang.StartRow - 1, FSelectCellRang.StartCol, vRow, vCol);

        if (vRow >= 0) and (vCol >= 0) then
        begin
          FSelectCellRang.StartRow := vRow;
          FSelectCellRang.StartCol := vCol;
          Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectLastItemAfterWithCaret;
          Result := True;
        end;
      end;
    end
    {$ENDREGION}
    else
    {$REGION 'VK_DOWN'}
    if AKey = VK_DOWN then
    begin
      if (vEditCell.CellData.SelectLastLine) and (FSelectCellRang.StartRow < Self.RowCount - 1) then  // ����һ�е�Ԫ��
      begin
        GetDestCell(FSelectCellRang.StartRow + 1, FSelectCellRang.StartCol, vRow, vCol);
        if ((vRow <> FSelectCellRang.StartRow) or (vCol <> FSelectCellRang.StartCol))  // ͬ����һ����Ԫ���Ŀ�겻����
          and (vRow >= 0) and (vCol >= 0)
        then  // ��һ������Ч�ĵ�Ԫ��
        begin
          FSelectCellRang.StartRow := vRow;
          FSelectCellRang.StartCol := vCol;
          Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectFirstItemBeforWithCaret;
          Result := True;
        end;
      end;
    end;
    {$ENDREGION}
  end;

var
  vOldKey: Word;
begin
  Self.SizeChanged := False;

  vEditCell := GetEditCell;
  if vEditCell <> nil then
  begin
    vOldKey := Key;
    case Key of
      VK_BACK, VK_DELETE, VK_RETURN, VK_TAB:
        begin
          CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
            procedure
            begin
              vEditCell.CellData.KeyDown(vOldKey, Shift);
            end);
        end;

      VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END:
        begin
          vEditCell.CellData.KeyDown(vOldKey, Shift);
          if (vOldKey = 0) and IsDirectionKey(Key) then  // ��Ԫ��Dataû�������Ƿ����
          begin
            if DoCrossCellKey(Key) then  // ������ƶ���������Ԫ��
            begin
              OwnerData.Style.UpdateInfoReCaret;
              Key := vOldKey;
            end;
          end;
        end;
    end;
  end
  else
    Key := 0;
end;

procedure THCTableItem.KeyPress(var Key: Char);
var
  vOldKey: Char;
  vEditCell: THCTableCell;
begin
  Self.SizeChanged := False;

  vEditCell := GetEditCell;
  if vEditCell <> nil then
  begin
    vOldKey := Key;
    CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
      procedure
      begin
        vEditCell.CellData.KeyPress(vOldKey);
      end);
    Key := vOldKey;
  end;
end;

procedure THCTableItem.KillFocus;
begin
  // ��������Ԫ��ѡ�У��������ʼ�����ٵ���ᰴ����ѡ�д�����ѡ�а��������ѱ����
  // �����ⲿ����������ʱҲ�Ѿ�ʧȥ�˰���ʱ�����У�����Ҫô����ʼ����Ҫô���׳�ʼ��
  //Self.InitializeMouseInfo;
end;

procedure THCTableItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  i, vR, vC, vWidth: Integer;
  vAutoHeight: Boolean;
  vRow: THCTableRow;
begin
  FRows.Clear;
  inherited LoadFromStream(AStream, AStyle, AFileVersion);

  AStream.ReadBuffer(FBorderVisible, SizeOf(FBorderVisible));
  AStream.ReadBuffer(vR, SizeOf(vR));  // ����
  AStream.ReadBuffer(vC, SizeOf(vC));  // ����
  { �����С��� }
  for i := 0 to vR - 1 do
  begin
    vRow := THCTableRow.Create(OwnerData.Style, vC);  // ע���д���ʱ��tableӵ���ߵ�Style������ʱ�Ǵ����AStyle
    FRows.Add(vRow);
  end;

  { ���ظ��б�׼��� }
  FColWidths.Clear;
  for i := 0 to vC - 1 do
  begin
    AStream.ReadBuffer(vWidth, SizeOf(vWidth));
    FColWidths.Add(vWidth);
  end;

  { ���ظ������� }
  for vR := 0 to FRows.Count - 1 do
  begin
    AStream.ReadBuffer(vAutoHeight, SizeOf(Boolean));
    FRows[vR].AutoHeight := vAutoHeight;
    if not FRows[vR].AutoHeight then
    begin
      AStream.ReadBuffer(vWidth, SizeOf(Integer));
      FRows[vR].Height := vWidth;
    end;
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      FRows[vR].Cols[vC].CellData.Width := FColWidths[vC] - 2 * FCellHPadding;
      FRows[vR].Cols[vC].LoadFromStream(AStream, AStyle, AFileVersion);
    end;
  end;
end;

procedure THCTableItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vMouseDownRow, vMouseDownCol: Integer;// abstract vBottom;
  vCell: THCTableCell;
  vCellPt: TPoint;
begin
  FMouseLBDowning := (Button = mbLeft) and (Shift = [ssLeft]);
  FOutSelectInto := False;
  FSelecting := False;  // ׼����ѡ
  FDraging := False;  // ׼����ק
  FOutsideInfo.Row := -1;

  FResizeInfo := GetCellAt(X, Y, vMouseDownRow, vMouseDownCol);

  Resizing := (Button = mbLeft) and (
    (FResizeInfo.TableSite = tsBorderRight) or (FResizeInfo.TableSite = tsBorderBottom));
  if Resizing then
  begin
    FMouseDownRow := vMouseDownRow;
    FMouseDownCol := vMouseDownCol;
    FMouseDownX := X;
    FMouseDownY := Y;
    OwnerData.Style.UpdateInfoRePaint;
    Exit;
  end;

  if FResizeInfo.TableSite = tsCell then
  begin
    if CoordInSelect(X, Y) then  // ��ѡ�������У��������߿��߼��߿����ݲ
    begin
      if FMouseLBDowning then
        FDraging := True;

      FMouseDownRow := vMouseDownRow;  // ��¼��ק��ʼ��Ԫ��
      FMouseDownCol := vMouseDownCol;

      vCellPt := GetCellPostion(FMouseDownRow, FMouseDownCol);
      FRows[FMouseDownRow].Cols[FMouseDownCol].CellData.MouseDown(
        Button, Shift, X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
    end
    else  // ����ѡ��������
    begin
      // �����ִ�� DisSelect �����Mouse��Ϣ�����µ�ǰ�༭��Ԫ������Ӧȡ�������¼�
      if (vMouseDownRow <> FMouseDownRow) or (vMouseDownCol <> FMouseDownCol) then  // ��λ��
      begin
        vCell := GetEditCell;
        if vCell <> nil then  // ȡ��ԭ���༭
          vCell.Active := False;

        OwnerData.Style.UpdateInfoReCaret;
      end;

      DisSelect;  // ���ԭѡ��

      FMouseDownRow := vMouseDownRow;
      FMouseDownCol := vMouseDownCol;

      FSelectCellRang.StartRow := FMouseDownRow;
      FSelectCellRang.StartCol := FMouseDownCol;

      vCellPt := GetCellPostion(FMouseDownRow, FMouseDownCol);

      FRows[FMouseDownRow].Cols[FMouseDownCol].CellData.MouseDown(
        Button, Shift, X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
    end;
  end
  else  // ���ڵ�Ԫ����
  begin
    DisSelect;  // ȡ��ԭ��ѡ��
    Self.InitializeMouseInfo;

    if FResizeInfo.TableSite = tsOutside then  // ��������Χ
    begin
      FOutsideInfo.Row := vMouseDownRow;  // ���ұ�ʱ��Ӧ����
      FOutsideInfo.Leftside := X < 0;  // ���
    end;
  end;
end;

procedure THCTableItem.MouseLeave;
begin
  inherited;
  if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;
  if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
    FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // .MouseMove([], -1, -1);  // ����������ϸ�����Ѹ���Ƴ������ָܻ�������

  if not SelectExists then
    Self.InitializeMouseInfo;
end;

procedure THCTableItem.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vMoveRow, vMoveCol: Integer;

  {$REGION 'AdjustSelectRang'}
  procedure AdjustSelectRang;
  var
    vRow, vCol: Integer;
  begin
    // �������ʼ��Ԫ��֮��ģ��Ա��������´���ѡ�е�Ԫ���ȫѡ
    if FSelectCellRang.StartRow >= 0 then
    begin
      for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          if ((vRow = FMouseDownRow) and (vCol = FMouseDownCol))
            //or ((vRow = vMoveRow) and (vCol = vMoveCol))
          then  // ������ǰ���µ�ѡ����Ϣ����ֹ�ص������������ݵ�ѡ��

          else
          begin
            if Cells[vRow, vCol].CellData <> nil then
              Cells[vRow, vCol].CellData.DisSelect;
          end;
        end;
      end;
    end;

    if FMouseDownRow < 0 then  // �ӱ������ѡ������
    begin
      if vMoveRow = 0 then  // ������ѡ��
      begin
        FMouseDownRow := 0;
        FMouseDownCol := 0;

        FSelectCellRang.StartRow := FMouseDownRow;
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndRow := vMoveRow;
        FSelectCellRang.EndCol := vMoveCol;
      end
      else  // ������ѡ��
      begin
        GetDestCell(Self.RowCount - 1, Self.FColWidths.Count - 1, vRow, vCol);
        FMouseDownRow := vRow;
        FMouseDownCol := vCol;

        FSelectCellRang.StartRow := vMoveRow;
        FSelectCellRang.StartCol := vMoveCol;
        FSelectCellRang.EndRow := FMouseDownRow;
        FSelectCellRang.EndCol := FMouseDownCol;
      end;

      {with Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData do
      begin
        SelectInfo.StartItemNo := 0;
        SelectInfo.StartItemOffset := 0;
      end;}

      FOutSelectInto := True;
    end
    else
    if FMouseMoveRow > FMouseDownRow then  // �ƶ����ڰ���������
    begin
      FSelectCellRang.StartRow := FMouseDownRow;
      FSelectCellRang.EndRow := FMouseMoveRow;

      if FMouseMoveCol < FMouseDownCol then  // �ƶ����ڰ�����ǰ��
      begin
        FSelectCellRang.StartCol := FMouseMoveCol;
        FSelectCellRang.EndCol := FMouseDownCol;
      end
      else
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end;
    end
    else
    if FMouseMoveRow < FMouseDownRow then  // �ƶ����ڰ���������
    begin
      FSelectCellRang.StartRow := FMouseMoveRow;
      FSelectCellRang.EndRow := FMouseDownRow;

      if FMouseMoveCol < FMouseDownCol then  // �ƶ����ڰ�����ǰ��
      begin
        FSelectCellRang.StartCol := FMouseMoveCol;
        FSelectCellRang.EndCol := FMouseDownCol;
      end
      else  // �ƶ����ڰ���ǰ����
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end;
    end
    else  // FMouseMoveRow = FMouseDownRow �ƶ��� = ������
    begin
      FSelectCellRang.StartRow := FMouseDownRow;
      FSelectCellRang.EndRow := FMouseMoveRow;

      if FMouseMoveCol > FMouseDownCol then  // �ƶ����ڰ������ұ�
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end
      else
      if FMouseMoveCol < FMouseDownCol then  // �ƶ����ڰ��������
      begin
        FSelectCellRang.StartCol := FMouseMoveCol;
        FSelectCellRang.EndCol := FMouseDownCol;
      end
      else  // �ƶ��� = ������
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end;
    end;

    if (FSelectCellRang.StartRow = FSelectCellRang.EndRow)
      and (FSelectCellRang.StartCol = FSelectCellRang.EndCol)
    then  // ������ϲ�ʱ��ѡ����ͬһ��Ԫ��
    begin
      FSelectCellRang.EndRow := -1;
      FSelectCellRang.EndCol := -1;
    end
    else
    begin
      if FRows[FSelectCellRang.StartRow].Cols[FSelectCellRang.StartCol].IsMergeSource then  // ��ʼѡ���ںϲ�Դ
      begin
        GetDestCell(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vRow, vCol);
        FSelectCellRang.StartRow := vRow;
        FSelectCellRang.StartCol := vCol;
      end;

      if FRows[FSelectCellRang.EndRow].Cols[FSelectCellRang.EndCol].IsMergeDest then  // �����ںϲ�Ŀ��
      begin
        GetSourceCell(FSelectCellRang.EndRow, FSelectCellRang.EndCol, vRow, vCol);  // ��ȡĿ�귽��������ݵ���Ŀ��õ�����Դ
        FSelectCellRang.EndRow := vRow;
        FSelectCellRang.EndCol := vCol;
      end;

      if (FSelectCellRang.StartRow = FSelectCellRang.EndRow)
        and (FSelectCellRang.StartCol = FSelectCellRang.EndCol)
      then  // �����ϲ�����ͬһ��Ԫ��
      begin
        FSelectCellRang.EndRow := -1;
        FSelectCellRang.EndCol := -1;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'MatchCellSelectState'}
  procedure MatchCellSelectState;
  var
    vRow, vCol: Integer;
  begin
    if not FSelectCellRang.EditCell then
    begin
      for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          {if (vRow = vMoveRow) and (vCol = vMoveCol) then else ʲô�������Ҫ����?}
          if Cells[vRow, vCol].CellData <> nil then
            Cells[vRow, vCol].CellData.SelectAll;
        end;
      end;
    end;
  end;
  {$ENDREGION}

var
  vCellPt: TPoint;
  vResizeInfo: TResizeInfo;
begin
  if ActiveDataResizing then
  begin
    vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MouseMove(
      Shift, X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);

    Exit;
  end;

  if Resizing then  // (ssLeft in Shift)
  begin
    FResizeInfo.DestX := X;
    FResizeInfo.DestY := Y;
    OwnerData.Style.UpdateInfoRePaint;

    Exit;
  end;

  vResizeInfo := GetCellAt(X, Y, vMoveRow, vMoveCol);

  if vResizeInfo.TableSite = tsCell then  // ����ڵ�Ԫ����
  begin
    if FMouseLBDowning or (Shift = [ssLeft]) then  // ��������ƶ�������ʱ�ڱ���� or û���ڱ���ϰ���(��ѡ����)
    begin
      if FDraging or OwnerData.Style.UpdateInfo.Draging then
      begin
        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;
        vCellPt := GetCellPostion(FMouseMoveRow, FMouseMoveCol);
        Cells[FMouseMoveRow, FMouseMoveCol].CellData.MouseMove(Shift,
          X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);

        Exit;
      end;

      if not FSelecting then
        FSelecting := True;

      if (vMoveRow <> FMouseMoveRow) or (vMoveCol <> FMouseMoveCol) then  // ����ƶ����µ�Ԫ��
      begin
        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;

        AdjustSelectRang;  // ����ѡ����ʼ������Χ(������Ӻ�����ǰѡ�����)
        MatchCellSelectState;  // ����ѡ�з�Χ�ڸ���Ԫ���ѡ��״̬
      end;

      {if (FSelectCellRang.StartRow = FMouseMoveRow)
        and (FSelectCellRang.StartCol = FMouseMoveCol)
      then}  // ѡ����ʼ��������ͬһ����Ԫ��
      begin
        vCellPt := GetCellPostion(FMouseMoveRow, FMouseMoveCol);
        Cells[FMouseMoveRow, FMouseMoveCol].CellData.MouseMove(Shift,
          X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
      end;
    end
    else  // ����ƶ���û�а�������
    begin
      if (vMoveRow <> FMouseMoveRow) or (vMoveCol <> FMouseMoveCol) then  // ����ƶ����µ�Ԫ��
      begin
        if (FMouseMoveRow >= 0) and (FMouseMoveCol >= 0) then
        begin
          if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
            FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // .MouseMove(Shift, -1, -1);  // �ɵ�Ԫ���Ƴ�
        end;

        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;
      end;

      if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;

      vCellPt := GetCellPostion(FMouseMoveRow, FMouseMoveCol);
      FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseMove(Shift,
        X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
    end;
  end
  else  // ��겻�ڵ�Ԫ����
  begin
    if (FMouseMoveRow >= 0) and (FMouseMoveCol >= 0) then
    begin
      if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
        FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // .MouseMove(Shift, -1, -1);  // �ɵ�Ԫ���Ƴ�
    end;

    FMouseMoveRow := -1;
    FMouseMoveCol := -1;

    if vResizeInfo.TableSite = tsBorderRight then // ��겻�ڵ�Ԫ����
      GCursor := crHSplit
    else
    if vResizeInfo.TableSite = tsBorderBottom then
      GCursor := crVSplit;
  end;
end;

procedure THCTableItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vPt: TPoint;
  vUpRow, vUpCol: Integer;
  vResizeInfo: TResizeInfo;
  //vMouseUpInSelect: Boolean;
begin
  FMouseLBDowning := False;

  if ActiveDataResizing then
  begin
    vPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MouseUp(
      Button, Shift, X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);

    Exit;
  end;

  if Resizing then  // �϶��ı��п���Ԫ��Data��ȵĸı������¸�ʽ������
  begin
    if FResizeInfo.TableSite = tsBorderRight then  // �Ͽ�/��խ
    begin
      vPt.X := X - FMouseDownX;  // ��ʹ��FResizeInfo.DestX(����ɰ��´�����Ҳ��ƫ��)
      if vPt.X <> 0 then
      begin
        // AReDestΪFalse���ڴ����϶��ı��п�ʱ�����϶������Ǻϲ�Դ�������д��в��޺ϲ�����
        // ��ʱ�������ȡ�϶���Ŀ���б�����������϶������в�û���
        vResizeInfo := GetCellAt(FMouseDownX, FMouseDownY, vUpRow, vUpCol, False{ʵ��λ�ô�����});

        if (vResizeInfo.TableSite <> tsOutside) and (vPt.X <> 0) then  // û����������
        begin
          if vPt.X > 0 then  // �Ͽ���
          begin
            if vUpCol < FColWidths.Count - 1 then  // �Ҳ��У��Ҳ��խ����С����С���
            begin
              if FColWidths[vUpCol + 1] - vPt.X < MinColWidth then
                vPt.X := FColWidths[vUpCol + 1] - MinColWidth;

              if vPt.X <> 0 then
              begin
                Undo_ColResize(vUpCol, FColWidths[vUpCol], FColWidths[vUpCol] + vPt.X);

                FColWidths[vUpCol] := FColWidths[vUpCol] + vPt.X;  // ��ǰ�б仯
                if vUpCol < FColWidths.Count - 1 then  // �Ҳ���ֲ��仯
                  FColWidths[vUpCol + 1] := FColWidths[vUpCol + 1] - vPt.X;
              end;
            end
            else  // ���Ҳ����Ͽ�
            begin
              {if FColWidths[vUpCol] + vPt.X > PageWidth then  ��ʱ�������϶�����ҳ��
                vPt.X := Width - FColWidths[vUpCol + 1];

              if vPt.X <> 0 then}
                FColWidths[vUpCol] := FColWidths[vUpCol] + vPt.X;  // ��ǰ�б仯

              Undo_ColResize(vUpCol, FColWidths[vUpCol], FColWidths[vUpCol] + vPt.X);
            end;
          end
          else  // ��խ��
          begin
            if FColWidths[vUpCol] + vPt.X < MinColWidth then  // С����С���
              vPt.X := MinColWidth - FColWidths[vUpCol];

            if vPt.X <> 0 then
            begin
              Undo_ColResize(vUpCol, FColWidths[vUpCol], FColWidths[vUpCol] + vPt.X);

              FColWidths[vUpCol] := FColWidths[vUpCol] + vPt.X;  // ��ǰ�б仯
              if vUpCol < FColWidths.Count - 1 then  // �Ҳ���ֲ��仯
                FColWidths[vUpCol + 1] := FColWidths[vUpCol + 1] - vPt.X;
            end;
          end;
        end;
      end;
    end
    else
    if FResizeInfo.TableSite = tsBorderBottom then  // �ϸ�/�ϰ�
    begin
      vPt.Y := Y - FMouseDownY;  // ��ʹ��FResizeInfo.DestY(����ɰ��´�����Ҳ��ƫ��)
      if vPt.Y <> 0 then
      begin
        Undo_RowResize(FMouseDownRow, FRows[FMouseDownRow].Height, FRows[FMouseDownRow].Height + vPt.Y);
        FRows[FMouseDownRow].Height := FRows[FMouseDownRow].Height + vPt.Y;
        FRows[FMouseDownRow].AutoHeight := False;
       end;
    end;

    FLastChangeFormated := False;
    Resizing := False;
    GCursor := crDefault;
    OwnerData.Style.UpdateInfoRePaint;
    OwnerData.Style.UpdateInfoReCaret;

    Exit;
  end;

  if FSelecting or OwnerData.Style.UpdateInfo.Selecting then  // ��ѡ���
  begin
    FSelecting := False;

    // ���ڰ��µ�Ԫ�����Ա㵥Ԫ����Ƕ�׵ı���л�����Ӧ����(ȡ�����¡���ѡ״̬����ѡ���)
    if (FMouseDownRow >= 0) and (not FOutSelectInto) then  // �ڱ���Ҳఴ���ƶ�ʱ�ٵ���ʱ����Ч��FMouseDownRow��FMouseDownCol
    begin
      vPt := GetCellPostion(FMouseDownRow, FMouseDownCol);
      Cells[FMouseDownRow, FMouseDownCol].CellData.MouseUp(Button, Shift,
        X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
    end;

    vResizeInfo := GetCellAt(X, Y, vUpRow, vUpCol);
    if vResizeInfo.TableSite = TTableSite.tsCell then  // û�л�ѡ��ҳ��հ׵ĵط�
    begin
      if (vUpRow <> FMouseDownRow) or (vUpCol <> FMouseDownCol) then  // ��ѡ��ɺ����ڷǰ��µ�Ԫ��
      begin
        vPt := GetCellPostion(vUpRow, vUpCol);
        Cells[vUpRow, vUpCol].CellData.MouseUp(Button, Shift,
          X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
      end;
    end;
  end
  else
  if FDraging or OwnerData.Style.UpdateInfo.Draging then  // ��ק����
  begin
    FDraging := False;

    vResizeInfo := GetCellAt(X, Y, vUpRow, vUpCol);

    if vResizeInfo.TableSite = TTableSite.tsCell then  // �ϵ���ĳ��Ԫ����
    begin
      DisSelect;
      FMouseMoveRow := vUpRow;  // ��קʱ�ĵ�Ԫ��λʹ�õ���MouseMove�������
      FMouseMoveCol := vUpCol;
      // ԭʼ����������ʵ��
      //DisSelectSelectedCell(vUpRow, vUpCol);  // ȡ��������֮���������קѡ�е�Ԫ���״̬
      //FRows[vUpRow].Cols[vUpCol].CellData.CellSelectedAll := False;
      //FSelectCellRang.Initialize;  // ׼�����¸�ֵ

      // �����Ƿ�����ѡ�е�Ԫ���е�����ק������Ҫ�༭��ѡ�е�Ԫ��
      FSelectCellRang.StartRow := vUpRow;
      FSelectCellRang.StartCol := vUpCol;
      vPt := GetCellPostion(vUpRow, vUpCol);
      Cells[vUpRow, vUpCol].CellData.MouseUp(Button, Shift,
        X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);

      {if FMouseDownRow >= 0 then  // �е��ʱ�ĵ�Ԫ��(����ǻ�ѡ��Χ������һ��������������ק�������ʱû�а���FMouseDownRow)
        Cells[FMouseDownRow, FMouseDownCol].CellData.InitializeField;}  // ��ק��ʼ��Ԫ�������ק�����
    end;
  end
  else  // �ǻ�ѡ������ק
  if FMouseDownRow >= 0 then  // �е��ʱ�ĵ�Ԫ��
  begin
    vPt := GetCellPostion(FMouseDownRow, FMouseDownCol);
    Cells[FMouseDownRow, FMouseDownCol].CellData.MouseUp(Button, Shift,
      X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
  end;
end;

procedure THCTableItem.ParseXml(const ANode: IHCXMLNode);
var
  i, vR, vC: Integer;
  vRow: THCTableRow;
  vSplit: TStringList;
begin
  FRows.Clear;

  inherited ParseXml(ANode);
  FBorderVisible := ANode.Attributes['bordervisible'];
  FBorderWidth := ANode.Attributes['borderwidth'];
  vR := ANode.Attributes['row'];
  vC := ANode.Attributes['col'];
  { �����С��� }
  for i := 0 to vR - 1 do
  begin
    vRow := THCTableRow.Create(OwnerData.Style, vC);  // ע���д���ʱ��tableӵ���ߵ�Style������ʱ�Ǵ����AStyle
    FRows.Add(vRow);
  end;

  { ���ظ��б�׼��� }
  FColWidths.Clear;
  vSplit := TStringList.Create;
  try
    vSplit.Delimiter := ',';
    vSplit.DelimitedText := ANode.Attributes['colwidth'];
    for i := 0 to vC - 1 do
      FColWidths.Add(StrToInt(vSplit[i]));
  finally
    FreeAndNil(vSplit);
  end;

  { ���ظ������� }
  for i := 0 to ANode.ChildNodes.Count - 1 do
    FRows[i].ParseXml(ANode.ChildNodes[i]);
end;

function THCTableItem.RowCanDelete(const ARow: Integer): Boolean;
var
  vCol: Integer;
begin
  Result := False;
  for vCol := 0 to FColWidths.Count - 1 do
  begin
    if FRows[ARow].Cols[vCol].RowSpan > 0 then  // �������кϲ�Ŀ�������ʱ��֧��
      Exit;
  end;
  Result := True;
end;

function THCTableItem.ClearFormatExtraHeight: Integer;
var
  vR, vC, vRowFrom, vOldHeight: Integer;
  vCell: THCTableCell;
begin
  Result := 0;

  if Self.Height = FFormatHeight then Exit;

  vOldHeight := Height;
  vRowFrom := -1;
  for vR := FRows.Count - 1 downto 0 do
  begin
    if FRows[vR].FmtOffset <> 0 then  // ����Ҫ���¼���߶ȣ�����Ҫ���²���
    begin
      vRowFrom := vR;
      FRows[vR].FmtOffset := 0;
    end;

    for vC := 0 to ColCount - 1 do
    begin
      vCell := FRows[vR].Cols[vC];
      if (vCell.ClearFormatExtraHeight <> 0)  // �ж���ĸ߶�
        or (  // ��ҳ�������һ�зǺϲ���Ԫ������ܺϲ���Ԫ��Ӱ�챻�Ÿߣ�
              // ClearFormatExtraHeightʱ����0������������Ҫ���¼���߶�
              Assigned(vCell.CellData)
              and (vCell.Height <> FCellHPadding + vCell.CellData.Height + FCellHPadding)
            )
      then  // ��Ҫ���¼���߶�
      begin
        vRowFrom := vR;
        CalcRowCellHeight(vR);
      end;
    end;
  end;

  if vRowFrom >= 0 then  // ��Ҫ���²��ֵĵ�1��
  begin
    CalcMergeRowHeightFrom(vRowFrom);
    Self.Height := GetFormatHeight;
    Result := vOldHeight - Self.Height;
  end;
end;

function THCTableItem.GetFormatHeight: Integer;
var
  i: Integer;
begin
  Result := FBorderWidth;
  for i := 0 to RowCount - 1 do
    Result := Result + FRows[i].Height + FBorderWidth;

  FFormatHeight := Result;
end;

function THCTableItem.GetHint: string;
var
  vCell: THCTableCell;
begin
  Result := inherited GetHint;
  if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;
  vCell := Cells[FMouseMoveRow, FMouseMoveCol];
  if (vCell <> nil) and (vCell.CellData <> nil) then
    Result := vCell.CellData.GetHint;
end;

function THCTableItem.GetCells(ARow, ACol: Integer): THCTableCell;
begin
  Result := FRows[ARow].Cols[ACol];
end;

function THCTableItem.GetColCount: Integer;
begin
  Result := FColWidths.Count;
end;

function THCTableItem.GetColWidth(AIndex: Integer): Integer;
begin
  Result := FColWidths[AIndex];
end;

procedure THCTableItem.GetDestCell(const ARow, ACol: Cardinal; var ADestRow,
  ADestCol: Integer);
begin
  if Cells[ARow, ACol].CellData <> nil then
  begin
    ADestRow := ARow;
    ADestCol := ACol;
  end
  else
  begin
    ADestRow := ARow + Cells[ARow, ACol].RowSpan;
    ADestCol := ACol + Cells[ARow, ACol].ColSpan;
  end;
end;

procedure THCTableItem.GetEditCell(var ARow, ACol: Integer);
begin
  ARow := -1;
  ACol := -1;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    ARow := FSelectCellRang.StartRow;
    ACol := FSelectCellRang.StartCol;
  end;
end;

function THCTableItem.GetEditCell: THCTableCell;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol]
  else
    Result := nil;
end;

function THCTableItem.GetCellAt(const X, Y: Integer; var ARow, ACol: Integer;
  const AReDest: Boolean = True): TResizeInfo;

  {$REGION 'CheckRowBorderRang'}
  function CheckRowBorderRang(const ABottom: Integer): Boolean;
  begin
    Result := (Y >= ABottom - GripSize) and (Y <= ABottom + GripSize);  // �Ƿ����б߿�����
  end;
  {$ENDREGION}

  {$REGION 'CheckColBorderRang'}
  function CheckColBorderRang(const ALeft: Integer): Boolean;
  begin
    Result := (X >= ALeft - GripSize) and (X <= ALeft + GripSize);  // �Ƿ����б߿�����
  end;
  {$ENDREGION}

var
  i, vTop, vBottom, vDestRow, vDestCol: Integer;
  vLeft: Integer absolute vTop;
  vRight: Integer absolute vBottom;
begin
  Result.TableSite := tsOutside;
  Result.DestX := -1;
  Result.DestY := -1;

  ARow := -1;
  ACol := -1;

  if (Y < 0) or (Y > Height) then Exit;

  if (X < 0) or (X > Width) then  // ���ڱ����ʱ���ж϶�Ӧλ�õ��У������ʹ��
  begin
    vTop := FBorderWidth;
    for i := 0 to RowCount - 1 do
    begin
      vTop := vTop + FRows[i].FmtOffset;  // ��ʵ������TopΪ��λ�ã��������п�ҳʱ������һҳ�ײ����ѡ�е�����һҳ��һ��
      vBottom := vTop + FRows[i].Height + FBorderWidth;

      if (vTop < Y) and (vBottom > Y) then  // �ڴ�����
      begin
        ARow := i;
        Break;
      end;
      vTop := vBottom;
    end;

    Exit;
  end;

  { ��ȡ�Ƿ����л��еı߿��� }
  // �ж��Ƿ������ϱ߿�
  vTop := FBorderWidth;
  if CheckRowBorderRang(vTop) then  // ��һ�����ϱ߿�
  begin
    Result.TableSite := tsBorderTop;
    Exit;
  end;
  // �ж��Ƿ�������߿�
  if CheckColBorderRang(vTop) then
  begin
    Result.TableSite := tsBorderLeft;
    Exit;
  end;

  // �ж������б߿��ϻ�������
  for i := 0 to RowCount - 1 do
  begin
    vTop := vTop + FRows[i].FmtOffset;  // ��ʵ������TopΪ��λ�ã��������п�ҳʱ������һҳ�ײ����ѡ�е�����һҳ��һ��
    vBottom := vTop + FRows[i].Height + FBorderWidth;
    if CheckRowBorderRang(vBottom) then  // ��i���±߿�
    begin
      ARow := i;
      Result.TableSite := tsBorderBottom;
      Result.DestY := vBottom;
      Break;  // Ϊ����絥Ԫ��ѡʱ�������±߿�ʱACol<0����м�ѡ�е�Ҳ�����Ե������⣬�������������Ҳ���ʱExit
    end;
    if (vTop < Y) and (vBottom > Y) then  // �ڴ�����
    begin
      ARow := i;
      Break;
    end;
    vTop := vBottom;
  end;

  if ARow < 0 then Exit;

  // �ж������б߿��ϻ�������
  vLeft := FBorderWidth;
  for i := 0 to FColWidths.Count - 1 do
  begin
    vRight := vLeft + FColWidths[i] + FBorderWidth;
    GetDestCell(ARow, i, vDestRow, vDestCol);
    if CheckColBorderRang(vRight) then  // ��i���ұ߿�
    begin
      ACol := i;
      if vDestCol + Cells[vDestRow, vDestCol].ColSpan <> i then  // ���б߿�ʱ���Ҳ��Ǻϲ�Դ�����һ�У����ڵ�Ԫ���д���
        Result.TableSite := tsCell
      else
        Result.TableSite := tsBorderRight;

      Result.DestX := vRight;

      Break;
    end;
    if (vLeft < X) and (vRight > X) then  // �ڴ�����
    begin
      ACol := i;
      if (Result.TableSite = tsBorderBottom)
        and (vDestRow + Cells[vDestRow, vDestCol].RowSpan <> ARow)
      then  // ���б߿�ʱ���Ҳ��Ǻϲ�Դ�����һ�У����ڵ�Ԫ���д���
        Result.TableSite := tsCell;

      Break;
    end;
    vLeft := vRight;
  end;

  if ACol >= 0 then  // ��ȷ���ĵ�Ԫ��
  begin
    if Result.TableSite = tsOutside then  // ��������Ϊ��Ԫ����
      Result.TableSite := tsCell;

    if AReDest and (Cells[ARow, ACol].CellData = nil) then // ����Ǳ��ϲ��ĵ�Ԫ�񣬷��غϲ���ĵ�Ԫ��
      GetDestCell(ARow, ACol, ARow, ACol);
  end;
end;

function THCTableItem.GetCellPostion(const ARow, ACol: Integer): TPoint;
var
  i: Integer;
begin
  Result.X := FBorderWidth;
  Result.Y := FBorderWidth;
  for i := 0 to ARow - 1 do
    Result.Y := Result.Y + FRows[i].FmtOffset + FRows[i].Height + FBorderWidth;
  Result.Y := Result.Y + FRows[ARow].FmtOffset;
  for i := 0 to ACol - 1 do
    Result.X := Result.X + FColWidths[i] + FBorderWidth;
end;

{function THCTableItem.GetMergeDestCellData(const ARow,
  ACol: Integer): THCTableCellData;
var
  vDestRow, vDestCol: Integer;
begin
  GetMergeDest(ARow, ACol, vDestRow, vDestCol);
  Result := Cells[vDestRow, vDestCol].CellData;
end;}

procedure THCTableItem.GetMergeDest(const ARow, ACol: Integer; var ADestRow,
  ADestCol: Integer);
begin
  ADestRow := ARow;
  ADestCol := ACol;

  if Cells[ARow, ACol].RowSpan < 0 then
    ADestRow := ADestRow + Cells[ARow, ACol].RowSpan;

  if Cells[ARow, ACol].ColSpan < 0 then
    ADestCol := ADestCol + Cells[ARow, ACol].ColSpan;
end;

// ��ʱû��ע�͵��ˣ�������߼����ӣ���ò�Ҫɾ���Ա���
//procedure THCTableItem.GetPageFmtBottomInfo(const AHeight: Integer;
//  var ADItemMostBottom: Integer);
//var
//  i, j, vPageLastRow, vTop, vBottom: Integer;
//  vCellData: THCTableCellData;
//begin
//  ADItemMostBottom := Height;  // GetFormatHeight;
//  if ADItemMostBottom < AHeight then  // ������嶼�ܷ��� �� 20160323002 ���
//    Exit;
//  vTop := FBorderWidth;
//  vPageLastRow := RowCount - 1;
//  for i := 0 to RowCount - 1 do  // ��һ�г����߶�(��ҳ��)
//  begin
//    vBottom := vTop + FRows[i].Height;
//    if vBottom > AHeight then
//    begin
//      vPageLastRow := i;
//      Break;
//    end
//    else
//      vTop := vBottom + FBorderWidth;
//  end;
//
//  ADItemMostBottom := 0;
//  // ����vPageLastRow���������һҳ��ʼ�����(������� 2016-3-23_001.bmp)
//  for i := 0 to FRows[vPageLastRow].ColCount - 1 do
//  begin
//    if Cells[vPageLastRow, i].CellData = nil then
//      Continue;
//    vCellData := Cells[vPageLastRow, i].CellData;
//    if vCellData.DrawItems[0].Rect.Bottom + vTop > AHeight
//    then  // ���vPageLastRow�������еĵ�1��������һҳ��˵�����д���һҳ��ʼ����ʱ��ǰҳ����һ��
//    begin
//      Dec(vPageLastRow);  // ��һ��
//      // ������һ�еĵײ�λ��
//      //ADItemMostBottom := FBorderWidth;
//      for j := 0 to vPageLastRow do
//        ADItemMostBottom := ADItemMostBottom + FBorderWidth + FRows[i].Height;
//      Exit;
//    end;
//  end;
//  // vPageLastRow�дӵ�ǰҳ��ʼ
//  for i := 0 to FRows[vPageLastRow].ColCount - 1 do
//  begin
//    if Cells[vPageLastRow, i].CellData = nil then
//      Continue;
//    vCellData := Cells[vPageLastRow, i].CellData;
//    vBottom := vCellData.DrawItems[0].Rect.Bottom + vTop;
//    if ADItemMostBottom < vBottom then
//      ADItemMostBottom := vBottom;
//    for j := 1 to vCellData.DrawItems.Count - 1 do
//    begin
//      vBottom := vCellData.DrawItems[j].Rect.Bottom + vTop;
//      if vBottom > AHeight then  // ��ǰDItem����һҳ
//      begin
//        if ADItemMostBottom <
//          vCellData.DrawItems[j - 1].Rect.Bottom + vTop
//        then
//          ADItemMostBottom := vCellData.DrawItems[j - 1].Rect.Bottom + vTop;
//      end;
//    end;
//  end;
//end;

function THCTableItem.GetResizing: Boolean;
begin
  Result := (inherited GetResizing) or ActiveDataResizing;
end;

function THCTableItem.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function THCTableItem.GetSelectComplate: Boolean;
begin
  Result := // ���ж��Ƿ�ȫ����Ԫ��ѡ���ˣ���������ո���Ԫ���ѡ��״̬
    //(not ((RowCount = 1) and (FRows[0].ColCount = 1)))  // ����ֻ��һ����Ԫ��
    (FSelectCellRang.StartRow = 0)
    and (FSelectCellRang.StartCol = 0)
    and (FSelectCellRang.EndRow = FRows.Count - 1)
    and (FSelectCellRang.EndCol = FColWidths.Count - 1);
end;

procedure THCTableItem.GetSourceCell(const ARow, ACol: Cardinal; var ASrcRow,
  ASrcCol: Integer);
begin
  if Cells[ARow, ACol].CellData <> nil then
  begin
    ASrcRow := ARow + FRows[ARow].Cols[ACol].RowSpan;
    ASrcCol := ACol + FRows[ARow].Cols[ACol].ColSpan;
  end
  else  // Դ��Ԫ���ܻ�ȡԴ��Ԫ��
    raise Exception.Create(HCS_EXCEPTION_VOIDSOURCECELL);
end;

function THCTableItem.GetTopLevelDataAt(const X, Y: Integer): THCCustomData;
var
  vResizeInfo: TResizeInfo;
  vRow, vCol: Integer;
  vCellPt: TPoint;
begin
  Result := nil;
  vResizeInfo := GetCellAt(X, Y, vRow, vCol);
  if (vRow < 0) or (vCol < 0) then Exit;
  vCellPt := GetCellPostion(vRow, vCol);
  Result := (Cells[vRow, vCol].CellData as THCRichData).GetTopLevelDataAt(
    X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
end;

procedure THCTableItem.InitializeCellData(const ACellData: THCTableCellData);
begin
  ACellData.OnInsertItem := (OwnerData as THCViewData).OnInsertItem;
  ACellData.OnRemoveItem := (OwnerData as THCViewData).OnRemoveItem;
  ACellData.OnItemMouseUp := (OwnerData as THCViewData).OnItemMouseUp;
  ACellData.OnCreateItemByStyle := (OwnerData as THCViewData).OnCreateItemByStyle;
  ACellData.OnDrawItemPaintAfter := (OwnerData as THCViewData).OnDrawItemPaintAfter;
  ACellData.OnInsertAnnotate := (OwnerData as THCViewData).OnInsertAnnotate;
  ACellData.OnRemoveAnnotate := (OwnerData as THCViewData).OnRemoveAnnotate;
  ACellData.OnDrawItemAnnotate := (OwnerData as THCViewData).OnDrawItemAnnotate;
  ACellData.OnCanEdit := (OwnerData as THCViewData).OnCanEdit;

  ACellData.OnItemResized := (OwnerData as THCRichData).OnItemResized;
  ACellData.OnCurParaNoChange := (OwnerData as THCRichData).OnCurParaNoChange;
  ACellData.OnDrawItemPaintAfter := (OwnerData as THCRichData).OnDrawItemPaintAfter;
  ACellData.OnDrawItemPaintBefor := (OwnerData as THCRichData).OnDrawItemPaintBefor;
  ACellData.OnCreateItem := (OwnerData as THCRichData).OnCreateItem;

  ACellData.OnGetUndoList := Self.GetSelfUndoList;
  ACellData.OnGetRootData := DoCellDataGetRootData;
end;

procedure THCTableItem.InitializeMouseInfo;
begin
  //FSelectCellRang.Initialize;  // ��ɱ���е����������ߴ��壨ʧȥ���㴥��KillFocus����������Ԫʱʧ��
  FMouseDownRow := -1;
  FMouseDownCol := -1;
  FMouseMoveRow := -1;
  FMouseMoveCol := -1;
  FMouseLBDowning := False;
end;

function THCTableItem.InsertCol(const ACol, ACount: Integer): Boolean;
var
  i, j, vRow, vWidth: Integer;
  viDestRow, viDestCol: Integer;
  vCell: THCTableCell;
begin
  Result := False;
  { TODO : ���ݸ��е�ǰ��ƽ������һ���Ŀ�ȸ�Ҫ������� }
  vWidth := MinColWidth - FBorderWidth;
  for i := 0 to ACount - 1 do
  begin
    for vRow := 0 to RowCount - 1 do
    begin
      vCell := THCTableCell.Create(OwnerData.Style);
      vCell.Width := vWidth;
      InitializeCellData(vCell.CellData);

      if (ACol < FColWidths.Count) and (FRows[vRow].Cols[ACol].ColSpan < 0) then  // �ϲ���Դ��
      begin
        GetDestCell(vRow, ACol, viDestRow, viDestCol);  // Ŀ������

        // �²�������ڵ�ǰ�к��棬Ҳ��Ϊ���ϲ�����
        vCell.CellData.Free;
        vCell.CellData := nil;
        vCell.RowSpan := FRows[vRow].Cols[ACol].RowSpan;
        vCell.ColSpan := FRows[vRow].Cols[ACol].ColSpan;

        for j := ACol to viDestCol + Cells[viDestRow, viDestCol].ColSpan do  // ��������Ŀ��Զ1
          FRows[vRow].Cols[j].ColSpan := FRows[vRow].Cols[j].ColSpan - 1;  // ��Ŀ����Զ1

        if vRow = viDestRow + FRows[viDestRow].Cols[viDestCol].RowSpan then  // �ϲ���Χ�ڵ��ж���������ٽ�Ŀ���з�Χ���󣬷�����ǰ������������ԭλ��Զ��Ŀ��ʱȡ�ķ�Χ��Խ��
          FRows[viDestRow].Cols[viDestCol].ColSpan := FRows[viDestRow].Cols[viDestCol].ColSpan + 1;
      end;

      FRows[vRow].Insert(ACol, vCell);
    end;

    FColWidths.Insert(ACol, vWidth);  // �Ҳ������
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Self.SizeChanged := True;
  FLastChangeFormated := False;
  Result := True;
end;

function THCTableItem.InsertColAfter(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;

  if vCell.ColSpan > 0 then
    Result := InsertCol(FSelectCellRang.StartCol + vCell.ColSpan + 1, ACount)
  else
    Result := InsertCol(FSelectCellRang.StartCol + 1, ACount);
end;

function THCTableItem.InsertColBefor(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;

  Result := InsertCol(FSelectCellRang.StartCol, ACount);
end;

function THCTableItem.InsertItem(const AItem: THCCustomItem): Boolean;
var
  vCell: THCTableCell;
  vResult: Boolean;
begin
  Result := False;
  vCell := GetEditCell;
  if not Assigned(vCell) then Exit;

  CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
    procedure
    begin
      //DoGetSelfUndoList.NewUndo(0, 0);
      //Self.Undo_StartRecord;
      vResult := vCell.CellData.InsertItem(AItem);
    end);

  Result := vResult;
end;

function THCTableItem.InsertRow(const ARow, ACount: Integer): Boolean;
var
  i, j, vCol, viDestRow, viDestCol: Integer;
  vTableRow: THCTableRow;
begin
  Result := False;
  for i := 0 to ACount - 1 do
  begin
    vTableRow := THCTableRow.Create(OwnerData.Style, FColWidths.Count);
    for vCol := 0 to FColWidths.Count - 1 do
    begin
      vTableRow.Cols[vCol].Width := FColWidths[vCol];

      if (ARow < FRows.Count) and (FRows[ARow].Cols[vCol].RowSpan < 0) then  // �ںϲ���Դ��Ԫ��ǰ�����
      begin
        GetDestCell(ARow, vCol, viDestRow, viDestCol);

        vTableRow.Cols[vCol].CellData.Free;
        vTableRow.Cols[vCol].CellData := nil;
        vTableRow.Cols[vCol].RowSpan := FRows[ARow].Cols[vCol].RowSpan;
        vTableRow.Cols[vCol].ColSpan := FRows[ARow].Cols[vCol].ColSpan;

        for j := ARow to viDestRow + Cells[viDestRow, viDestCol].RowSpan do  // Ŀ����п�� - �Ѿ����
          FRows[j].Cols[vCol].RowSpan := FRows[j].Cols[vCol].RowSpan - 1;  // ��Ŀ����Զ1

        if vCol = viDestCol + Cells[viDestRow, viDestCol].ColSpan then
          FRows[viDestRow].Cols[viDestCol].RowSpan := FRows[viDestRow].Cols[viDestCol].RowSpan + 1;  // Ŀ���а����ĺϲ�Դ����1
      end;
    end;

    FRows.Insert(ARow, vTableRow);
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Self.SizeChanged := True;
  FLastChangeFormated := False;
  Result := True;
end;

function THCTableItem.InsertRowAfter(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;

  if vCell.RowSpan > 0 then
    Result := InsertRow(FSelectCellRang.StartRow + vCell.RowSpan + 1, ACount)
  else
    Result := InsertRow(FSelectCellRang.StartRow + 1, ACount);
end;

function THCTableItem.InsertRowBefor(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;

  Result := InsertRow(FSelectCellRang.StartRow, ACount);
end;

function THCTableItem.InsertStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.InsertStream(AStream, AStyle, AFileVersion);
end;

function THCTableItem.InsertText(const AText: string): Boolean;
var
  vResult: Boolean;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
      procedure
      var
        vEditCell: THCTableCell;
      begin
        vEditCell := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol];
        vResult := vEditCell.CellData.InsertText(AText);
      end);

    Result := vResult;
  end
  else
    Result := inherited InsertText(AText);
end;

function THCTableItem.IsSelectComplateTheory: Boolean;
begin
  Result := IsSelectComplate;
end;

procedure THCTableItem.MarkStyleUsed(const AMark: Boolean);
var
  vR, vC: Integer;
begin
  inherited;
  for vR := 0 to FRows.Count - 1 do
  begin
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      if FRows[vR].Cols[vC].CellData <> nil then
        FRows[vR].Cols[vC].CellData.MarkStyleUsed(AMark);
    end;
  end;
end;

function THCTableItem.MergeCells(const AStartRow, AStartCol, AEndRow,
  AEndCol: Integer): Boolean;

  procedure DeleteEmptyRows(const ASRow, AERow: Cardinal);
  var
    vR, vC, vR1: Integer;
    vEmptyRow: Boolean;
  begin
    for vR := AERow downto ASRow do  // ������
    begin
      vEmptyRow := True;
      for vC := 0 to FRows[vR].ColCount - 1 do  // ��ǰ�и���
      begin
        if FRows[vR].Cols[vC].CellData <> nil then  // ����û�б��ϲ�����
        begin
          vEmptyRow := False;  // ���ǿ���
          Break;
        end;
      end;

      if vEmptyRow then  // ����
      begin
        for vR1 := 0 to vR - 1 do
        begin
          for vC := 0 to FRows[vR1].ColCount - 1 do
          begin
            if Cells[vR1, vC].RowSpan > 0 then
              Cells[vR1, vC].RowSpan := Cells[vR1, vC].RowSpan - 1;
          end;
        end;

        for vR1 := vR + 1 to FRows.Count - 1 do
        begin
          for vC := 0 to FRows[vR1].ColCount - 1 do
          begin
            if Cells[vR1, vC].RowSpan < 0 then
              Cells[vR1, vC].RowSpan := Cells[vR1, vC].RowSpan + 1;
          end;
        end;

        FRows.Delete(vR);  // ɾ����ǰ����
      end;
    end;
  end;

  procedure DeleteEmptyCols(const ASCol, AECol: Cardinal);
  var
    vR, vC, vC2: Integer;
    vEmptyCol: Boolean;
    vTableCell: THCTableCell;
  begin
    for vC := AECol downto ASCol do  // ѭ������
    begin
      vEmptyCol := True;
      for vR := 0 to RowCount - 1 do  // ѭ������
      begin
        if FRows[vR].Cols[vC].CellData <> nil then  // ĳ�еĵ�vC��û�б��ϲ�
        begin
          vEmptyCol := False;
          Break;
        end;
      end;

      if vEmptyCol then  // �ǿ���
      begin
        for vR := RowCount - 1 downto 0 do  // ѭ�����У�ɾ����Ӧ��
        begin
          for vC2 := 0 to vC - 1 do
          begin
            vTableCell := FRows[vR].Cols[vC2];
            if vC2 + vTableCell.ColSpan >= vC then
              vTableCell.ColSpan := vTableCell.ColSpan - 1;
          end;

          for vC2 := vC + 1 to FRows[vR].ColCount - 1 do
          begin
            vTableCell := FRows[vR].Cols[vC2];
            if vC2 + vTableCell.ColSpan < vC then
              vTableCell.ColSpan := vTableCell.ColSpan + 1;
          end;

          FRows[vR].Delete(vC);  // ɾ����
        end;

        FColWidths[vC - 1] := FColWidths[vC -1] + FBorderWidth + FColWidths[vC];
        FColWidths.Delete(vC);
      end;
    end;
  end;

var
  vR, vC, vEndRow, vEndCol: Integer;  // �����Ľ���λ��
begin
  Result := False;
  vEndRow := AEndRow;
  vEndCol := AEndCol;

  AdjustCellRange(AStartRow, AStartCol, vEndRow, vEndCol);

  Result := CellsCanMerge(AStartRow, AStartCol, vEndRow, vEndCol);
  if not Result then Exit;

  // ���������У����жϺ���ʼ�С��кͽ����С������һ����������
  if AStartRow = vEndRow then  // ͬһ�кϲ�
  begin
    for vC := AStartCol + 1 to vEndCol do  // �ϲ���
    begin
      if FRows[AStartRow].Cols[vC].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        Cells[AStartRow, AStartCol].CellData.AddData(Cells[AStartRow, vC].CellData);
        Cells[AStartRow, vC].CellData.Free;
        Cells[AStartRow, vC].CellData := nil;
        //Cells[AStartRow, vC].RowSpan := 0;
      end;

      Cells[AStartRow, vC].ColSpan := AStartCol - vC;
    end;

    Cells[AStartRow, AStartCol].ColSpan := vEndCol - AStartCol;  // �ϲ�Դ����

    DeleteEmptyCols(AStartCol + 1, vEndCol);
    Result := True;
  end
  else
  if AStartCol = vEndCol then  // ͬ�кϲ�
  begin
    for vR := AStartRow + 1 to vEndRow do  // �ϲ�����
    begin
      if FRows[vR].Cols[AStartCol].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[vR].Cols[AStartCol].CellData);
        FRows[vR].Cols[AStartCol].CellData.Free;
        FRows[vR].Cols[AStartCol].CellData := nil;
        //Cells[vR, AStartCol].ColSpan := 0;
      end;

      Cells[vR, AStartCol].RowSpan := AStartRow - vR;
    end;

    FRows[AStartRow].Cols[AStartCol].RowSpan := vEndRow - AStartRow;

    DeleteEmptyRows(AStartRow + 1, vEndRow);
    Result := True;
  end
  else  // ��ͬ�У���ͬ��
  begin
    for vC := AStartCol + 1 to vEndCol do  // ��ʼ�и��кϲ�
    begin
      if FRows[AStartRow].Cols[vC].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[AStartRow].Cols[vC].CellData);
        FRows[AStartRow].Cols[vC].CellData.Free;
        FRows[AStartRow].Cols[vC].CellData := nil;
      end;

      FRows[AStartRow].Cols[vC].RowSpan := 0;
      FRows[AStartRow].Cols[vC].ColSpan := AStartCol - vC;
    end;

    for vR := AStartRow + 1 to vEndRow do  // ʣ���и��кϲ�
    begin
      for vC := AStartCol to vEndCol do
      begin
        if FRows[vR].Cols[vC].CellData <> nil then
        begin
          FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[vR].Cols[vC].CellData);
          FRows[vR].Cols[vC].CellData.Free;
          FRows[vR].Cols[vC].CellData := nil;
        end;

        FRows[vR].Cols[vC].ColSpan := AStartCol - vC;
        FRows[vR].Cols[vC].RowSpan := AStartRow - vR;
      end;
    end;

    FRows[AStartRow].Cols[AStartCol].RowSpan := vEndRow - AStartRow;
    FRows[AStartRow].Cols[AStartCol].ColSpan := vEndCol - AStartCol;

    DeleteEmptyRows(AStartRow + 1, vEndRow);
    // ɾ������
    DeleteEmptyCols(AStartCol + 1, vEndCol);

    Result := True;
  end;
end;

function THCTableItem.MergeSelectCells: Boolean;
var
  vSelRow, vSelCol: Integer;
begin
  if (FSelectCellRang.StartRow >= 0) and (FSelectCellRang.EndRow >= 0) then
  begin
    Undo_MergeCells;

    Result := MergeCells(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
      FSelectCellRang.EndRow, FSelectCellRang.EndCol);
    if Result then
    begin
      FLastChangeFormated := False;
      { ��ֹ�ϲ����п��л���б�ɾ����DisSelect����Խ�磬���Ժϲ���ֱ�Ӹ�ֵ������Ϣ }
      vSelRow := FSelectCellRang.StartRow;
      vSelCol := FSelectCellRang.StartCol;
      FSelectCellRang.EndRow := -1;
      FSelectCellRang.EndCol := -1;
      DisSelect;

      FSelectCellRang.StartRow := vSelRow;
      FSelectCellRang.StartCol := vSelCol;
      Self.Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.InitializeField;
    end;
  end
  else
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MergeTableSelectCells
  else
    Result := False;
end;

procedure THCTableItem.CalcRowCellHeight(const ARow: Integer);
var
  vC, vNorHeightMax: Integer;
begin
  vNorHeightMax := 0;  // ����δ�����ϲ�����ߵ�Ԫ��
  for vC := 0 to FRows[ARow].ColCount - 1 do  // �õ�����δ�����ϲ�Data������ߵĵ�Ԫ��߶�
  begin
    if (FRows[ARow].Cols[vC].CellData <> nil)  // ���Ǳ��ϲ��ĵ�Ԫ��
      and (FRows[ARow].Cols[vC].RowSpan = 0)  // �����кϲ����е�Ԫ��
    then
      vNorHeightMax := Max(vNorHeightMax, FRows[ARow].Cols[vC].CellData.Height);
  end;

  vNorHeightMax := FCellHPadding + vNorHeightMax + FCellHPadding;  // �������±߾�
  for vC := 0 to FRows[ARow].ColCount - 1 do  // ����
    FRows[ARow].Cols[vC].Height := vNorHeightMax;

  if FRows[ARow].AutoHeight then  // �����и�δ�����кϲ���������ߵ�Ϊ�и�
    FRows[ARow].Height := vNorHeightMax
  else  // �϶��ı��˸߶�
  begin
    if vNorHeightMax > FRows[ARow].Height then  // �϶��߶�ʧЧ
    begin
      FRows[ARow].AutoHeight := True;
      FRows[ARow].Height := vNorHeightMax;
    end;
  end;
end;

function THCTableItem.CanDrag: Boolean;
begin
  Result := inherited CanDrag;
  if Result then
  begin
    if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
      Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectedCanDrag
    else
      Result := Self.IsSelectComplate or Self.IsSelectPart;
  end;
end;

procedure THCTableItem.CellChangeByAction(const ARow, ACol: Integer; const AProcedure: THCProcedure);
begin
  AProcedure();
  if not Self.SizeChanged then
    Self.SizeChanged := Cells[ARow, ACol].CellData.FormatHeightChange;

  FLastChangeFormated := not Self.SizeChanged;
end;

function THCTableItem.CellsCanMerge(const AStartRow, AStartCol, AEndRow, AEndCol: Integer): Boolean;
var
  vR, vC: Integer;
begin
  Result := False;

  for vR := AStartRow to AEndRow do
  begin
    for vC := AStartCol to AEndCol do
    begin
      if FRows[vR].Cols[vC].CellData <> nil then
      begin
        if not FRows[vR].Cols[vC].CellData.CellSelectedAll then
          Exit;
      end;
    end;
  end;

  Result := True;

  {GetDestCell(AStartRow, AStartCol, vStartDestRow, vStartDestCol);
  vCell := FRows[vStartDestRow].Cols[vStartDestCol];
  vStartDestRow := vStartDestRow + vCell.RowSpan;
  vStartDestCol := vStartDestCol + vCell.ColSpan;

  // ������Ԫ�����Ч��Χ
  GetDestCell(AEndRow, AEndCol, vEndDestRow, vEndDestCol);
  vCell := FRows[vEndDestRow].Cols[vEndDestCol];
  vEndDestRow := vEndDestRow + vCell.RowSpan;
  vEndDestCol := vEndDestCol + vCell.ColSpan;

  if vStartDestRow = vEndDestRow then
    Result := vStartDestCol < vEndDestCol
  else
  if vStartDestRow < vEndDestRow then
    Result := vStartDestCol <= vEndDestCol;}
end;

procedure THCTableItem.CheckFormatPageBreak(const APageIndex, ADrawItemRectTop,
  ADrawItemRectBottom, APageDataFmtTop, APageDataFmtBottom, AStartRow: Integer;
  var ABreakRow, AFmtOffset, ACellMaxInc: Integer);

  procedure AddPageBreak(const ARow, ABreakSeat: Integer);
  var
    vPageBreak: TPageBreak;
  begin
    vPageBreak := TPageBreak.Create;
    vPageBreak.PageIndex := APageIndex;  // ��ҳʱ��ǰҳ���
    vPageBreak.Row := ARow;  // ��ҳ��
    vPageBreak.BreakSeat := ABreakSeat;  // ��ҳʱ�����и��з�ҳλ������
    vPageBreak.BreakBottom := APageDataFmtBottom - ADrawItemRectTop;  // ��ҳʱ��ҳ�ײ�λ�þ��ҳ�������ľ���(��ҳ�ж��ٿռ������ű��)

    FPageBreaks.Add(vPageBreak);
  end;

var
  /// <summary> ��ҳ��δ��ҳʱ��ʽ����ʼλ�ã�������� </summary>
  vBreakRowFmtTop,
  /// <summary> ��ҳ�н���λ�ã����ײ����� </summary>
  vBreakRowBottom,
  /// <summary> ���һ��DrawItem�ײ������еײ��ľ��� </summary>
  vLastDFromRowBottom,
  /// <summary> ��Ԫ�����ݶ���(���ϲ���Ԫ���ҳʱ��Ŀ�굥Ԫ��Ϊ׼) </summary>
  vDestCellDataFmtTop,
  /// <summary> ��ǰDItem����ƫ�ƶ��ٿ�����ʾ����һҳ���� </summary>
  vH,
  /// <summary> ��ǰ�з�ҳ�����ӵĸ߶� </summary>
  vCellInc,
  vDestRow, vDestCol,  // �ϲ���Ŀ�굥Ԫ��
  /// <summary> ��ҳʱ�����и��з�ҳλ������(����ڱ�񶥲��ĸ߶�) </summary>
  vRowBreakSeat,
  vPageBreakBottom
    :Integer;
  i, vR, vC: Integer;
  vCellData: THCTableCellData;
  vDrawItem: THCCustomDrawItem;
  vFirstLinePlace  // ����Ԫ��������һ�����ݿ��ڷ�ҳλ������������ʾ
    : Boolean;
  vColCross: TColCross;
  vColCrosses: TObjectList<TColCross>;  // ��¼��ҳ�и��з�ҳ��ʼDrawItem�ͷ�ҳƫ��
begin
  ABreakRow := -1;
  AFmtOffset := 0;
  ACellMaxInc := 0;  // vCellInc�����ֵ����ʾ��ǰ�и���Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�����ߵ�

  { �õ���ʼ�е�Fmt��ʼλ�� }
  vBreakRowFmtTop := ADrawItemRectTop + FBorderWidth - 1;  // ��1���Ű�λ��(�ϱ߿��߽���λ��)����Ϊ�߿���ADrawItemRectTopҲռ1���أ�����Ҫ����
  for vR := 0 to AStartRow - 1 do
    vBreakRowFmtTop := vBreakRowFmtTop + FRows[vR].FmtOffset + FRows[vR].Height + FBorderWidth;  // ��i�н���λ��(���±߿����λ��)

  vBreakRowFmtTop := vBreakRowFmtTop + FRows[AStartRow].FmtOffset;  // �ټ�����ʼ������������ƫ�Ƶ����

  { ����ʼ�п�ʼ��⵱ǰҳ�Ƿ��ܷ����� }
  vR := AStartRow;
  while vR < Self.RowCount do  // ����ÿһ��
  begin
    vBreakRowBottom := vBreakRowFmtTop + FRows[vR].FmtOffset + FRows[vR].Height + FBorderWidth;  // ��i�н���λ��(���±߿����λ��)
    if vBreakRowBottom > APageDataFmtBottom then  // ��i�н���λ�ó���ҳ���ݽ���λ�ã��Ų���
    begin
      ABreakRow := vR;  // ��i����Ҫ�����ҳ
      Break;
    end;
    vBreakRowFmtTop := vBreakRowBottom;  // ��i+1����ʼλ��(�ϱ߿����λ��)

    Inc(vR);
  end;

  if ABreakRow < 0 then Exit;  // ������ڵ�ǰҳ����

  if (not Self.CanPageBreak) and (ABreakRow = 0) then  // ���֧�ַ�ҳ�����ڵ�ǰҳһ��Ҳ�Ų��£��������Ƶ���һҳ
  begin
    //if vRowDataFmtTop < APageDataFmtTop then  // �����жϣ�������ڵ�2ҳ��1��ʱ��׼ȷ ��ǰҳ��ʼItem���ǵ�ǰ��񣨱���ǵ�ǰҳ��һ��Item���ͷ�ҳ��ͬ����ҳ��ȻҲ�ǵ�һ������������ʼλ�ò����ڷ�ҳ���ҳ��
    //begin
      AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
      Exit;
    //end;
  end;

  // ���Ų��£���Ҫ�ضϣ�����ضϷ�ҳ�Ĺ���
  // 1.�ȼ������ҳ�ض�λ��
  // 2.����λ�ã��жϸ��������Ƶ���һҳ���ӵ�ƫ����
  // 3.����ƫ�ƣ����ƫ����Ϊ0Ҫ��������Ԫ��ƫ�����ӵ������ӵ���Height�����򸽼ӵ�FmtOffset
  // 4.������ƫ�Ƶģ�����Data���DrawItem��ƫ��

  {$REGION ' 1.�Ų��£����жϷ�ҳλ�ã���һ����APageDataFmtBottom�������Ƿ�ҳ����ƫ���ж���' }
  vFirstLinePlace := True;
  vPageBreakBottom := APageDataFmtBottom;

  // ���ж��ǲ����е�Ԫ�����һ�����ݾͷŲ��£���Ҫ�������ƣ������ĺô��ǣ����
  // ������Ҫ��������ʱ���������е�Ԫ�����кϲ�Դ������Ŀ��ײ�������Ҫ��ҳ����
  // ��ҳ���������ƺ󣬴�ҳ�Է�ҳ����һ�еײ�Ϊ������Ŀ����������г�������λ��
  // �ģ�Ҫ������λ����Ϊ��ҳ�ж�λ�ö�����ҳ�ײ�λ���ˡ�
  // ��ǰ�õ���Դ����Ҫ��������ʱ����������������һ�еײ���ΪĿ�굥Ԫ��Ľض�λ�á�
  for vC := 0 to FRows[ABreakRow].ColCount - 1 do  // �������е�Ԫ����DrawItem���Ҵ��ĸ���ʼ����ƫ�Ƽ�ƫ����
  begin
    if FRows[ABreakRow].Cols[vC].ColSpan < 0 then  // �ϲ�Ŀ��ֻ����Ŀ�굥Ԫ����
      Continue;

    GetMergeDest(ABreakRow, vC, vDestRow, vDestCol);
    vCellData := FRows[vDestRow].Cols[vDestCol].CellData;

    // ����Ŀ�굥Ԫ��������ʼλ��
    vDestCellDataFmtTop := vBreakRowFmtTop + FCellVPadding;  // ��ҳ�����ݻ�����ʼλ��

    if ABreakRow <> vDestRow then
      vDestCellDataFmtTop := vDestCellDataFmtTop - SrcCellDataDrawTopDistanceToDest(ABreakRow, vDestRow);

    // �жϺϲ�Ŀ�������ڵ�ǰ��ҳ�еķ�ҳλ��
    for i := 0 to vCellData.DrawItems.Count - 1 do
    begin
      vDrawItem := vCellData.DrawItems[i];
      if not vDrawItem.LineFirst then  // ֻ��Ҫ�ж�����ÿ�е�һ��
        Continue;

      if vDestCellDataFmtTop + vDrawItem.Rect.Bottom + FCellVPadding + FBorderWidth > APageDataFmtBottom then  // ��ǰDrawItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
      begin                                    // |���FBorderWidth���иߴ�Ͳ�����
        if i = 0 then  // ��һ��DrawItem�ͷŲ��£���Ҫ��������(����λ���������ж�)
        begin
          vFirstLinePlace := False;
          vPageBreakBottom := vBreakRowFmtTop;
          Break;
        end;
      end;
    end;

    if not vFirstLinePlace then
      Break;
  end;
  {$ENDREGION}

  // ���������������Ľض�λ��(������PageData�ײ�Ҳ���������������еײ�)
  // �������ݵ�ƫ�ƣ�ѭ��ԭ����������Ƿ�������������һ��
  vCellInc := 0;  // �и�����Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�
  vRowBreakSeat := 0;

  vColCrosses := TObjectList<TColCross>.Create;
  try

    {$REGION ' 2.��¼��ҳ���и���Ԫ����DrawItem��ҳʱ����ƫ�����͵�Ԫ��߶����ӵ��� '}
    for vC := 0 to FRows[ABreakRow].ColCount - 1 do  // �������е�Ԫ����DrawItem���Ҵ��ĸ���ʼ����ƫ�Ƽ�ƫ����
    begin
      if FRows[ABreakRow].Cols[vC].ColSpan < 0 then  // �ϲ�Դֻ����Ŀ�굥Ԫ����
        Continue;

      GetMergeDest(ABreakRow, vC, vDestRow, vDestCol);
      vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
      vLastDFromRowBottom :=  // ԭ���һ��DrawItem�ײ������еײ��Ŀհ׾���
        FRows[vDestRow].Cols[vDestCol].Height - (FCellVPadding + vCellData.Height + FCellVPadding);

      // ����Ŀ�굥Ԫ��������ʼλ��
      vDestCellDataFmtTop := vBreakRowFmtTop + FCellVPadding;  // ��ҳ��������ʼλ��
      if ABreakRow <> vDestRow then
        vDestCellDataFmtTop := vDestCellDataFmtTop - SrcCellDataDrawTopDistanceToDest(ABreakRow, vDestRow);
      //
      vColCross := TColCross.Create;
      vColCross.Col := vC;

      // �жϺϲ�Ŀ�������ڵ�ǰ��ҳ�еķ�ҳλ��
      for i := 0 to vCellData.DrawItems.Count - 1 do
      begin
        vDrawItem := vCellData.DrawItems[i];
        if not vDrawItem.LineFirst then  // ֻ��Ҫ�ж�����ÿ�е�һ��
          Continue;

        if vDestCellDataFmtTop + vDrawItem.Rect.Bottom + FCellVPadding + FBorderWidth > vPageBreakBottom then  // ��ǰDrawItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
        begin                                    // |���FBorderWidth���иߴ�Ͳ�����
            // �����ҳ��DrawItem����ƫ�ƶ��ٿ�����һҳȫ��ʾ��DrawItem
            vH := APageDataFmtBottom - (vDestCellDataFmtTop + vDrawItem.Rect.Top) // ҳData�ײ� - ��ǰDrawItem��ҳ�����λ��
              + FBorderWidth + FCellVPadding - 1;  // Ԥ���������߿��FCellVPadding����Ϊ�߿���APageDataFmtBottomҲռ1���أ�����Ҫ����

          // ��Ԫ��ʵ�����ӵĸ߶� = DrawItem��ҳ����ƫ�Ƶľ��� - ԭ���һ��DrawItem�ײ������еײ��Ŀհ׾���(�����ײ���FCellVPadding)
          if vH > vLastDFromRowBottom then  // ƫ�����ȵ�ǰ��Ԫ�������пհ״�ʱ�����㵥Ԫ������
            vCellInc := vH - vLastDFromRowBottom
          else  // ƫ�����õײ��հ׵�����
            vCellInc := 0;

          vColCross.DrawItemNo := i;  // �ӵ�j��DrawItem����ʼ��ҳ
          vColCross.VDrawOffset := vH;  // DrawItem��ҳƫ�ƣ�ע�⣬DrawItem����ƫ�ƺ͵�Ԫ�����ӵĸ߲���һ����ȣ���ԭ�ײ��пհ�ʱ����Ԫ�����Ӹ߶�<Draw����ƫ��

          if i > 0 then  // ���ܷ��µ�DrawItem
          begin
            if vDestCellDataFmtTop + vCellData.DrawItems[i - 1].Rect.Bottom + FCellVPadding + FBorderWidth > vRowBreakSeat then
              vRowBreakSeat := vDestCellDataFmtTop + vCellData.DrawItems[i - 1].Rect.Bottom + FCellVPadding + FBorderWidth;
          end
          else  // ��һ��DrawItem�ͷŲ���
          begin
            if vDestCellDataFmtTop > vRowBreakSeat then
              vRowBreakSeat := vDestCellDataFmtTop - FCellVPadding;
          end;

          Break;
        end;
      end;

      if ACellMaxInc < vCellInc then
        ACellMaxInc := vCellInc;  // ��¼�����з�ҳ����ƫ�Ƶ��������

      vColCrosses.Add(vColCross);
    end;

    vRowBreakSeat := vRowBreakSeat - ADrawItemRectTop + 1;  // ��ʼΪx���ض�Ϊy���ضϴ��߶���x-y+1
    {$ENDREGION}

    if not vFirstLinePlace then  // ĳ��Ԫ���һ�����ݾ��ڵ�ǰҳ�Ų����ˣ�������ҳ��������Ҫ���Ƶ���һҳ(������������0)
    begin
      //vRowBreakSeat := 0;

      if ABreakRow = 0 then  // ����һ�����е�Ԫ���ڵ�ǰҳ�Ų��£���Ҫ��������
      begin
        AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
        ACellMaxInc := 0;  // ��������ƫ��ʱ���ʹ����˵�һ�е�����ƫ�ƣ�����˵��һ�е�FmtOffset��Զ��0����Ϊ��������ƫ�Ƶ��������жϵ�һ��
        Exit;
      end;

      // 3.����ҳ������ĳԴ��Ӧ��Ŀ�굥Ԫ�������ڷ�ҳ��������ƫ����������ǰ����
      // ��ͨ��Ԫ�������ڶ�����ҳ��ƫ����Ϊ0(����Ҫƫ��)�����ֱ�ӽ�ƫ��������
      // �������ǲ���ȷ��(������ͨ��Ԫ������һҳ��ʼλ�ò���ҳ����)��Ӧ���ǽ�
      // ƫ�������ӵ����и߶�
      for i := 0 to vColCrosses.Count - 1 do  // vColCrosses��ֻ�кϲ�Ŀ�����ͨ��Ԫ��
      begin
        if (vColCrosses[i].VDrawOffset > 0) and (vColCrosses[i].DrawItemNo = 0) then  // ��һ���Ų�����Ҫ����ƫ��
        begin
          FRows[ABreakRow].FmtOffset := vColCrosses[i].VDrawOffset;  // ���������ƫ�ƺ�������ʼ����һҳ��ʾ��ͬ�ж����Ԫ���Ų��µ�һ��ʱ���ظ�����ֵͬ(�ظ���ֵ���в�һ����ֵ��)
          vColCrosses[i].VDrawOffset := 0;  // ����ƫ���ˣ�DrawItem�Ͳ��õ�����ƫ������
        end;
      end;
    end
    else
      FRows[ABreakRow].Height := FRows[ABreakRow].Height + ACellMaxInc;

    AddPageBreak(ABreakRow, vRowBreakSeat);

    for vC := 0 to vColCrosses.Count - 1 do  // ������������������ƫ�Ƶĵ�Ԫ�񣬽�ƫ����ɢ����ҳ�����DrawItem
    begin
      if (vColCrosses[vC].DrawItemNo < 0) or (vColCrosses[vC].VDrawOffset = 0) then  // ����Ҫƫ��
        Continue;

      GetMergeDest(ABreakRow, vColCrosses[vC].Col, vDestRow, vDestCol);
      vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
      for i := vColCrosses[vC].DrawItemNo to vCellData.DrawItems.Count - 1 do
        OffsetRect(vCellData.DrawItems[i].Rect, 0, vColCrosses[vC].VDrawOffset);
    end;

    // ��ǰ�з�ҳ�ĵ�Ԫ���еĿ����Ǻϲ�Դ��Ŀ���Ӧ��Դ�ڴ������棬����Ϊ��ʹ
    // ������Ԫ���ҳ���ӵ�ƫ�����ܹ����ݵ���Ӧ�Ľ�����Ԫ�񣬴ӷ�ҳ�����¸�ʽ��
    CalcMergeRowHeightFrom(ABreakRow);
  finally
    FreeAndNil(vColCrosses);
  end;
end;

procedure THCTableItem.CheckFormatPageBreakBefor;
begin
  FPageBreaks.Clear;
end;

function THCTableItem.ColCanDelete(const ACol: Integer): Boolean;
var
  vRow: Integer;
begin
  Result := False;
  for vRow := 0 to RowCount - 1 do
  begin
    if FRows[vRow].Cols[ACol].ColSpan > 0 then  // �кϲ�Ŀ�������ʱ��֧��
      Exit;
  end;
  Result := True;
end;

function THCTableItem.CoordInSelect(const X, Y: Integer): Boolean;
var
  vCellPt: TPoint;
  vCellData: THCTableCellData;
  vX, vY, vItemNo, vDrawItemNo, vOffset, vRow, vCol: Integer;
  vRestrain: Boolean;
  vResizeInfo: TResizeInfo;
begin
  Result := inherited CoordInSelect(X, Y);  // ��ѡ������RectItem������(���Թ���)
  if Result then
  begin
    vResizeInfo := GetCellAt(X, Y, vRow, vCol);  // ���괦��Ϣ
    Result := vResizeInfo.TableSite = TTableSite.tsCell;  // ���괦�ڵ�Ԫ���в��ڱ߿���
    if Result then  // �ڵ�Ԫ���У��жϵ�Ԫ���Ƿ���ѡ�з�Χ��
    begin
      if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
      begin
        if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
        begin
          Result := (vRow >= FSelectCellRang.StartRow)
                and (vRow <= FSelectCellRang.EndRow)
                and (vCol >= FSelectCellRang.StartCol)
                and (vCol <= FSelectCellRang.EndCol);
        end
        else  // ��ѡ������У��ж��Ƿ��ڵ�ǰ��Ԫ���ѡ����
        begin
          vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
          if vCellData.SelectExists then
          begin
            vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
            vX := X - vCellPt.X - FCellHPadding;
            vY := Y - vCellPt.Y - FCellVPadding;
            vCellData.GetItemAt(vX, vY, vItemNo, vOffset, vDrawItemNo, vRestrain);

            Result := vCellData.CoordInSelect(vX, vY, vItemNo, vOffset, vRestrain);
          end;
        end;
      end;
    end;

    {if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
    begin
      if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
      begin
        vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
        vSelRect.TopLeft := vCellPt;
        vCellPt := GetCellPostion(FSelectCellRang.EndRow, FSelectCellRang.EndCol);
        vSelRect.Right := vCellPt.X + FColWidths[FSelectCellRang.EndCol];
        vSelRect.Bottom := vCellPt.Y + FRows[FSelectCellRang.EndRow].Height;
        Result := PtInRect(vSelRect, Point(X, Y));
      end
      else  // ��ѡ������У��жϵ�ǰ��Ԫ���Ƿ���ѡ��
      begin
        vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
        if vCellData.SelectExists then
        begin
          vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
          vX := X - vCellPt.X - FCellHPadding;
          vY := Y - vCellPt.Y - FCellVPadding;
          vCellData.GetItemAt(vX, vY, vItemNo, vOffset, vDrawItemNo, vRestrain);

          Result := (not vRestrain) and vCellData.CoordInSelect(vX, vY, vItemNo, vOffset);
        end;
      end;
    end;}
  end;
end;

procedure THCTableItem.SaveSelectToStream(const AStream: TStream);
var
  vCellData: THCCustomData;
begin
  if Self.IsSelectComplate then  // ȫѡ����
    raise Exception.Create('����ѡ�����ݳ������Ӧ�����ڲ�����ȫѡ�еı��棡')
  else
  begin
    vCellData := GetActiveData;
    if vCellData <> nil then
      vCellData.SaveSelectToStream(AStream);
  end;
end;

procedure THCTableItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);
var
  i, vR, vC: Integer;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  AStream.WriteBuffer(FBorderVisible, SizeOf(FBorderVisible));
  AStream.WriteBuffer(FRows.Count, SizeOf(FRows.Count));  // ����
  AStream.WriteBuffer(FColWidths.Count, SizeOf(FColWidths.Count));  // ����

  for i := 0 to FColWidths.Count - 1 do  // ���б�׼���
  begin
    vC := FColWidths[i];
    AStream.WriteBuffer(vC, SizeOf(vC));
  end;

  for vR := 0 to FRows.Count - 1 do  // ��������
  begin
    AStream.WriteBuffer(FRows[vR].AutoHeight, SizeOf(Boolean));
    if not FRows[vR].AutoHeight then
      AStream.WriteBuffer(FRows[vR].Height, SizeOf(Integer));
    for vC := 0 to FRows[vR].ColCount - 1 do  // ��������
      FRows[vR].Cols[vC].SaveToStream(AStream);
  end;
end;

function THCTableItem.Search(const AKeyword: string; const AForward,
  AMatchCase: Boolean): Boolean;
var
  i, j, vRow, vCol: Integer;
begin
  Result := False;

  if AForward then  // ��ǰ����
  begin
    if FSelectCellRang.StartRow < 0 then  // û�б༭�ĵ�Ԫ��
    begin
      FSelectCellRang.StartRow := FRows.Count - 1;
      FSelectCellRang.StartCol := FColWidths.Count - 1;

      vRow := FSelectCellRang.StartRow;
      vCol := FSelectCellRang.StartCol;

      // �����ʼ
      if Cells[vRow, vCol].CellData <> nil then
      begin
        with Cells[vRow, vCol].CellData do
        begin
          SelectInfo.StartItemNo := Items.Count - 1;
          SelectInfo.StartItemOffset := GetItemOffsetAfter(Items.Count - 1);
        end;
      end;
    end;

    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;

    if (vRow >= 0) and (vCol >= 0) then
    begin
      if Cells[vRow, vCol].CellData <> nil then
        Result := Cells[vRow, vCol].CellData.Search(AKeyword, AForward, AMatchCase);

      if not Result then  // ��ǰ��Ԫ��û�ҵ�
      begin
        for j := vCol - 1 downto 0 do  // ��ͬ�к���ĵ�Ԫ����
        begin
          if (Cells[vRow, j].ColSpan < 0) or (Cells[vRow, j].RowSpan < 0) then
            Continue
          else
          begin
            with Cells[vRow, j].CellData do
            begin
              SelectInfo.StartItemNo := Items.Count - 1;
              SelectInfo.StartItemOffset := GetItemOffsetAfter(Items.Count - 1);
            end;

            Result := Cells[vRow, j].CellData.Search(AKeyword, AForward, AMatchCase);
          end;

          if Result then
          begin
            FSelectCellRang.StartCol := j;
            Break;
          end;
        end;
      end;

      if not Result then  // ͬ�к���ĵ�Ԫ��û�ҵ�
      begin
        for i := FSelectCellRang.StartRow - 1 downto 0 do
        begin
          for j := FColWidths.Count - 1 downto 0 do
          begin
            if (Cells[i, j].ColSpan < 0) or (Cells[i, j].RowSpan < 0) then
              Continue
            else
            begin
              with Cells[i, j].CellData do
              begin
                SelectInfo.StartItemNo := Items.Count - 1;
                SelectInfo.StartItemOffset := GetItemOffsetAfter(Items.Count - 1);
              end;

              Result := Cells[i, j].CellData.Search(AKeyword, AForward, AMatchCase);
            end;

            if Result then
            begin
              FSelectCellRang.StartCol := j;
              Break;
            end;
          end;

          if Result then
          begin
            FSelectCellRang.StartRow := i;
            Break;
          end;
        end;
      end;
    end;
  end
  else  // ������
  begin
    if FSelectCellRang.StartRow < 0 then  // û�б༭�ĵ�Ԫ��
    begin
      FSelectCellRang.StartRow := 0;
      FSelectCellRang.StartCol := 0;

      // ��ͷ��ʼ
      Cells[0, 0].CellData.SelectInfo.StartItemNo := 0;
      Cells[0, 0].CellData.SelectInfo.StartItemOffset := 0;
    end;

    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;

    if (vRow >= 0) and (vCol >= 0) then
    begin
      Result := Cells[vRow, vCol].CellData.Search(AKeyword, AForward, AMatchCase);
      if not Result then  // ��ǰ��Ԫ��û�ҵ�
      begin
        for j := vCol + 1 to FColWidths.Count - 1 do  // ��ͬ�к���ĵ�Ԫ����
        begin
          if (Cells[vRow, j].ColSpan < 0) or (Cells[vRow, j].RowSpan < 0) then
            Continue
          else
          begin
            Cells[vRow, j].CellData.SelectInfo.StartItemNo := 0;
            Cells[vRow, j].CellData.SelectInfo.StartItemOffset := 0;

            Result := Cells[vRow, j].CellData.Search(AKeyword, AForward, AMatchCase);
          end;

          if Result then
          begin
            FSelectCellRang.StartCol := j;
            Break;
          end;
        end;
      end;

      if not Result then  // ͬ�к���ĵ�Ԫ��û�ҵ�
      begin
        for i := FSelectCellRang.StartRow + 1 to FRows.Count - 1 do
        begin
          for j := 0 to FColWidths.Count - 1 do
          begin
            if (Cells[i, j].ColSpan < 0) or (Cells[i, j].RowSpan < 0) then
              Continue
            else
            begin
              Cells[i, j].CellData.SelectInfo.StartItemNo := 0;
              Cells[i, j].CellData.SelectInfo.StartItemOffset := 0;

              Result := Cells[i, j].CellData.Search(AKeyword, AForward, AMatchCase);
            end;

            if Result then
            begin
              FSelectCellRang.StartCol := j;
              Break;
            end;
          end;

          if Result then
          begin
            FSelectCellRang.StartRow := i;
            Break;
          end;
        end;
      end;
    end;
  end;

  if not Result then
    FSelectCellRang.Initialize;
end;

procedure THCTableItem.SelectAll;
begin
  SelectComplate;
end;

function THCTableItem.SelectExists: Boolean;
begin
  Result := False;
  if Self.IsSelectComplate then
    Result := True
  else
  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
      Result := True
    else  // ��ѡ������У��жϵ�ǰ��Ԫ���Ƿ���ѡ��
      Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectExists;
  end;

//  Result := (FSelectCellRang.StartRow >= 0) and (FSelectCellRang.EndRow >= 0);  // ����ѡ����ʼ�ͽ�����
//  if Result then
//  begin
//    if FSelectCellRang.SameCell then  // ѡ����ͬһ����Ԫ���У��ɵ�Ԫ������Ƿ���ѡ������
//      Result := CellSelectComplate(FSelectCellRang.StartRow, FSelectCellRang.StartCol)
//        or Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectExists;
//  end;
end;

procedure THCTableItem.SetActive(const Value: Boolean);
var
  vCell: THCTableCell;
begin
  if Self.Active <> Value then
  begin
    vCell := GetEditCell;
    if (vCell <> nil) and (vCell.CellData <> nil) then
      vCell.CellData.Active := Value;
    if not Value then
      Self.InitializeMouseInfo;

    inherited SetActive(Value);
  end;
end;

procedure THCTableItem.SetBorderWidth(const Value: Byte);
begin
  if FBorderWidth <> Value then
  begin
    if Value > FCellVPadding * 2 then  // Ҫ�󲻴�����С�иߣ������ҳ�����������
      FBorderWidth := FCellVPadding * 2 - 1
    else
      FBorderWidth := Value;
  end;
end;

procedure THCTableItem.SetCellVPadding(const Value: Byte);
begin
  if FCellVPadding <> Value then
  begin
    FCellVPadding := Value;
    if FBorderWidth > FCellVPadding * 2 then  // Ҫ�󲻴�����С�иߣ������ҳ�����������
      FBorderWidth := FCellVPadding * 2 - 1;
  end;
end;

procedure THCTableItem.SetColWidth(AIndex: Integer; const AWidth: Integer);
begin
  FColWidths[AIndex] := AWidth;
end;

procedure THCTableItem.SetResizing(const Value: Boolean);
begin
  inherited SetResizing(Value);
end;

function THCTableItem.SplitCurCol: Boolean;
var
  i, vR, vCurRow, vCurCol,
  vDestRow, vDestCol, vSrcRow, vSrcCol: Integer;
  vLeftCell: THCTableCell;
begin
  Result := False;

  // ���� vLeftCell ����
  vLeftCell := GetEditCell;
  if vLeftCell = nil then Exit;
  vLeftCell.CellData.InitializeField;

  vCurRow := FSelectCellRang.StartRow;
  vCurCol := FSelectCellRang.StartCol;

  // ���ʱ���������Ԫ��RowSpan>=0��ColSpan>=0
  if Cells[vCurRow, vCurCol].ColSpan > 0 then  // ���ʱ������ڵĵ�Ԫ�����кϲ�Ŀ�꣬���ϲ���
  begin
    GetSourceCell(vCurRow, vCurCol, vSrcRow, vSrcCol);  // �õ���Χ

    Cells[vCurRow, vCurCol].ColSpan := 0;  // �ϲ�Ŀ�겻�����Һϲ���Ԫ����
    for i := vCurCol + 1 to vSrcCol do  // Ŀ����ͬ���Ҳ���������úϲ�Ŀ��
    begin
      for vR := vCurRow to vSrcRow do  // �������ǰ������ڵ��и���
        Cells[vR, i].ColSpan := Cells[vR, i].ColSpan + 1;
    end;

    // ԭ�ϲ�Ŀ�굥Ԫ���Ҳ�ĵ�Ԫ����Ϊ��ֺ��Ҳ�ϲ�Դ����Ŀ��
    Cells[vCurRow, vCurCol + 1].CellData := THCTableCellData.Create(OwnerData.Style);
    Cells[vCurRow, vCurCol + 1].RowSpan := vSrcRow - vCurRow;
    Cells[vCurRow, vCurCol + 1].ColSpan := vSrcCol - (vCurCol + 1);
  end
  else  // Cells[vCurRow, vCurCol].ColSpan = 0 ���ʱ������ڵ�Ԫ������ͨ��Ԫ��
  if InsertCol(vCurCol + 1, 1) then  // �Ҳ������
  begin
    vR := 0;
    while vR < Self.RowCount do
    begin
      vLeftCell := Cells[vR, vCurCol];

      if vR = vCurRow then  // ���ʱ��������У���ʱvLeftCell.ColSpan = 0
      begin
        if vLeftCell.RowSpan > 0 then  // ǰ�����кϲ�Ŀ��
        begin
          vSrcRow := vCurRow + vLeftCell.RowSpan;
          while vR <= vSrcRow do
          begin
            Cells[vR, vCurCol + 1].RowSpan := Cells[vR, vCurCol].RowSpan;
            if Cells[vR, vCurCol + 1].RowSpan < 0 then
            begin
              Cells[vR, vCurCol + 1].CellData.Free;
              Cells[vR, vCurCol + 1].CellData := nil;
            end;

            Inc(vR);
          end;
        end
        else  // vLeftCell.RowSpan < 0 ����RowSpan > 0 �ﴦ���ˣ�vLeftCell.RowSpan = 0 ����Ҫ����
          Inc(vR);
      end
      else  // vR <> vCurRow
      begin
        if vLeftCell.RowSpan = 0 then
        begin
          if vLeftCell.ColSpan = 0 then  // �������ͨ��Ԫ��
          begin
            Cells[vR, vCurCol + 1].CellData.Free;
            Cells[vR, vCurCol + 1].CellData := nil;
            Cells[vR, vCurCol + 1].ColSpan := -1;
            vLeftCell.ColSpan := 1;
            Inc(vR);
          end
          else
          if vLeftCell.ColSpan < 0 then  // ͬ�кϲ���Դ��
          begin
            vDestCol := vCurCol + vLeftCell.ColSpan;  // Ŀ����
            vSrcCol := vDestCol + Cells[vR, vDestCol].ColSpan;
            if vCurCol = vSrcCol then  // ����Ǻϲ���Χ��󣬲������Ҫ�ϲ���ǰ��
            begin
              Cells[vR, vCurCol + 1].CellData.Free;
              Cells[vR, vCurCol + 1].CellData := nil;
              Cells[vR, vCurCol + 1].ColSpan := vLeftCell.ColSpan - 1;
              Cells[vR, vDestCol].ColSpan := Cells[vR, vDestCol].ColSpan + 1;
            end;

            Inc(vR);
          end
          else  // vLeftCell.ColSpan > 0 �����ͬ�кϲ�Ŀ�꣬���Ҳ�����д����˲����еĺϲ�
            Inc(vR);
        end
        else
        if vLeftCell.RowSpan > 0 then  // �ϲ�Ŀ��
        begin
          if vLeftCell.ColSpan = 0 then  // ͬ�кϲ����Ҳ����ĺϲ���Ŀ��
          begin
            vLeftCell.ColSpan := 1;
            vDestRow := vR;
            vSrcRow := vR + vLeftCell.RowSpan;

            while vR <= vSrcRow do
            begin
              Cells[vR, vCurCol + 1].CellData.Free;
              Cells[vR, vCurCol + 1].CellData := nil;
              Cells[vR, vCurCol + 1].RowSpan := vDestRow - vR;
              Cells[vR, vCurCol + 1].ColSpan := -1;
              Inc(vR);
            end;
          end
          else  // �ϲ�Ŀ�겻���� vLeftCell.ColSpan < 0��vLeftCell.ColSpan > 0���Ҳ�����д����˺ϲ�
            Inc(vR);
        end
        else  // vLeftCell.RowSpan < 0 ���������Ŀ�굥Ԫ����vLeftCell.RowSpan > 0�д�����
          Inc(vR);
      end;
    end;
  end;

  Result := True;
end;

function THCTableItem.SplitCurRow: Boolean;
var
  i, vC, vCurRow, vCurCol,
  vDestRow, vDestCol, vSrcRow, vSrcCol: Integer;
  vTopCell: THCTableCell;
begin
  Result := False;

  // ���� vTopCell ����
  vTopCell := GetEditCell;
  if vTopCell = nil then Exit;
  vTopCell.CellData.InitializeField;

  vCurRow := FSelectCellRang.StartRow;
  vCurCol := FSelectCellRang.StartCol;

  // ���ʱ���������Ԫ��RowSpan>=0��ColSpan>=0
  if Cells[vCurRow, vCurCol].RowSpan > 0 then  // ���ʱ������ڵĵ�Ԫ�����кϲ�Ŀ�꣬���ϲ���
  begin
    GetSourceCell(vCurRow, vCurCol, vSrcRow, vSrcCol);  // �õ���Χ

    Cells[vCurRow, vCurCol].RowSpan := 0;  // Ŀ�겻�����ºϲ���Ԫ����
    for i := vCurRow + 1 to vSrcRow do  // ��Ŀ������һ�п�ʼ���������úϲ�Ŀ��
    begin
      for vC := vCurCol to vSrcCol do  // �������ǰ������ڵ��и���
        Cells[i, vC].RowSpan := Cells[i, vC].RowSpan + 1;
    end;

    // ԭ�ϲ�Ŀ�굥Ԫ��������ĵ�Ԫ����Ϊ��ֺ�����ϲ�Դ����Ŀ��
    Cells[vCurRow + 1, vCurCol].CellData := THCTableCellData.Create(OwnerData.Style);
    Cells[vCurRow + 1, vCurCol].RowSpan := vSrcRow - (vCurRow + 1);
    Cells[vCurRow + 1, vCurCol].ColSpan := vSrcCol - vCurCol;
  end
  else  // Cells[vCurRow, vCurCol].RowSpan = 0 ���ʱ������ڵ�Ԫ������ͨ��Ԫ��
  if InsertRow(vCurRow + 1, 1) then  // ���������
  begin
    vC := 0;
    while vC < Self.ColCount do
    begin
      vTopCell := Cells[vCurRow, vC];

      if vC = vCurCol then  // ���ʱ��������У���ʱvTopCell.RowSpan = 0
      begin
        if vTopCell.ColSpan > 0 then  // �������кϲ�Ŀ��
        begin
          vSrcCol := vCurCol + vTopCell.ColSpan;
          while vC <= vSrcCol do
          begin
            Cells[vCurRow + 1, vC].ColSpan := Cells[vCurRow, vC].ColSpan;
            if Cells[vCurRow + 1, vC].ColSpan < 0 then
            begin
              Cells[vCurRow + 1, vC].CellData.Free;
              Cells[vCurRow + 1, vC].CellData := nil;
            end;

            Inc(vC);
          end;
        end
        else  // vLeftCell.ColSpan < 0 ����ColSpan > 0 �ﴦ���ˣ�vLeftCell.ColSpan = 0 ����Ҫ����
          Inc(vC);
      end
      else  // vC <> vCurCol
      begin
        if vTopCell.ColSpan = 0 then
        begin
          if vTopCell.RowSpan = 0 then  // ��������ͨ��Ԫ��
          begin
            Cells[vCurRow + 1, vC].CellData.Free;
            Cells[vCurRow + 1, vC].CellData := nil;
            Cells[vCurRow + 1, vC].RowSpan := -1;
            vTopCell.RowSpan := 1;
            Inc(vC);
          end
          else
          if vTopCell.RowSpan < 0 then  // ͬ�кϲ���Դ��
          begin
            vDestRow := vCurRow + vTopCell.RowSpan;  // Ŀ����
            vSrcRow := vDestRow + Cells[vDestRow, vC].RowSpan;
            if vCurRow = vSrcRow then  // �����Ǻϲ���Χ��󣬲������Ҫ�ϲ�������
            begin
              Cells[vCurRow + 1, vC].CellData.Free;
              Cells[vCurRow + 1, vC].CellData := nil;
              Cells[vCurRow + 1, vC].RowSpan := vTopCell.RowSpan - 1;
              Cells[vDestRow, vC].RowSpan := Cells[vDestRow, vC].RowSpan + 1;
            end;

            Inc(vC);
          end
          else  // vTopCell.RowSpan > 0 ������ͬ�кϲ�Ŀ�꣬����������д����˲����еĺϲ�
            Inc(vC);
        end
        else
        if vTopCell.ColSpan > 0 then  // �ϲ�Ŀ��
        begin
          if vTopCell.RowSpan = 0 then  // ͬ�кϲ����������ĺϲ���Ŀ��
          begin
            vTopCell.RowSpan := 1;
            vDestCol := vC;
            vSrcCol := vC + vTopCell.ColSpan;

            while vC <= vSrcCol do
            begin
              Cells[vCurRow + 1, vC].CellData.Free;
              Cells[vCurRow + 1, vC].CellData := nil;
              Cells[vCurRow + 1, vC].ColSpan := vDestCol - vC;
              Cells[vCurRow + 1, vC].RowSpan := -1;
              Inc(vC);
            end;
          end
          else  // �ϲ�Ŀ�겻���� vTopCell.RowSpan < 0��vTopCell.RowSpan > 0����������д����˺ϲ�
            Inc(vC);
        end
        else  // vLeftCell.ColSpan < 0 ���������Ŀ�굥Ԫ����vLeftCell.ColSpan > 0�д�����
          Inc(vC);
      end;
    end;



    {for vC := 0 to Self.ColCount - 1 do  // �������ǰ������ڵ��и���
    begin
      vTopCell := Cells[vCurRow, vC];
      if vTopCell.RowSpan > 0 then  // �ϲ�Ŀ���Ѿ��ڲ����з����д����˺ϲ�
      begin

      end
      else
      if vTopCell.RowSpan < 0 then  // �ϲ�Դ
      begin
        if vTopCell.ColSpan = 0 then  // �൥Ԫ��ϲ���ֻ����ʼ�д���Ŀ�굥Ԫ���кϲ���Χ������
        begin
          GetDestCell(vCurRow, vC, vDestRow, vDestCol);  // �õ�Ŀ��
          GetSourceCell(vDestRow, vDestCol, vSrcRow, vSrcCol);  // �õ���Χ

          if vCurRow = vSrcRow then  // ֻ�ڷ�Χ���һ��(���)�������ĲŴ���ϲ����м�(���)������Ѿ��ڲ����з����д����˺ϲ�
          begin
            Cells[vDestRow, vDestCol].RowSpan := Cells[vDestRow, vDestCol].RowSpan + 1;  // Ŀ���кϲ���Χ��1

            for i := vC to vSrcCol do  // �ϲ���Χ���һ���²�����и���Ҫ���CellData
            begin
              Cells[vCurRow + 1, i].CellData.Free;
              Cells[vCurRow + 1, i].CellData := nil;
              Cells[vCurRow + 1, i].RowSpan := vDestRow - (vCurRow + 1);
              Cells[vCurRow + 1, i].ColSpan := vC - i;
            end;
          end;
        end;
      end
      else
      if vTopCell.RowSpan = 0 then  // ��ͨ��Ԫ��
      begin
        if vC <> vCurCol then
        begin
          Cells[vCurRow + 1, vC].CellData.Free;
          Cells[vCurRow + 1, vC].CellData := nil;
          Cells[vCurRow + 1, vC].RowSpan := -1;
          Cells[vCurRow, vC].RowSpan := 1;
        end;
      end;
    end;}
  end;

  Result := True;
end;

function THCTableItem.SrcCellDataDrawTopDistanceToDest(const ASrcRow, ADestRow: Integer): Integer;
var
  vR: Integer;
begin
  Result := {FCellVPadding������ļ�Լ�� +} FBorderWidth + FRows[ASrcRow].FmtOffset;

  vR := ASrcRow - 1;
  while vR > ADestRow do
  begin
    Result := Result + FRows[vR].Height + FBorderWidth + FRows[vR].FmtOffset;
    Dec(vR);
  end;

  Result := Result + FRows[ADestRow].Height{ - FCellVPadding�������Լ��};
end;

procedure THCTableItem.SelectComplate;
var
  vRow, vCol: Integer;
begin
  inherited SelectComplate;

  FSelectCellRang.StartRow := 0;
  FSelectCellRang.StartCol := 0;
  FSelectCellRang.EndRow := Self.RowCount - 1;
  FSelectCellRang.EndCol := FColWidths.Count - 1;

  for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
  begin
    for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
    begin
      if FRows[vRow].Cols[vCol].CellData <> nil then
        FRows[vRow].Cols[vCol].CellData.SelectAll;
    end;
  end;
end;

function THCTableItem.SelectedCellCanMerge: Boolean;
var
  vEndRow, vEndCol: Integer;
begin
  Result := False;
  if FSelectCellRang.SelectExists then
  begin
    vEndRow := FSelectCellRang.EndRow;
    vEndCol := FSelectCellRang.EndCol;
    AdjustCellRange(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vEndRow, vEndCol);
    Result := CellsCanMerge(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vEndRow, vEndCol);
  end;
end;

function THCTableItem.ToHtml(const APath: string): string;
var
  vR, vC: Integer;
  vCell: THCTableCell;
begin
  Result := '<table border="' + IntToStr(FBorderWidth) + '" cellpadding="0"; cellspacing="0">';
  for vR := 0 to FRows.Count - 1 do
  begin
    Result := Result + sLineBreak + '<tr>';
    for vC := 0 to FColWidths.Count - 1 do
    begin
      vCell := Cells[vR, vC];
      if (vCell.RowSpan < 0) or (vCell.ColSpan < 0) then
        Continue;

      Result := Result + sLineBreak + Format('<td rowspan="%d"; colspan="%d"; width="%d"; height="%d">',
        [vCell.RowSpan + 1, vCell.ColSpan + 1, vCell.Width, vCell.Height]);

      if Assigned(vCell.CellData) then
        Result := Result + vCell.CellData.ToHtml(APath);

      Result := Result + sLineBreak + '</td>';
    end;
    Result := Result + sLineBreak + '</tr>';
  end;
  Result := Result + sLineBreak + '</table>';
end;

procedure THCTableItem.ToXml(const ANode: IHCXMLNode);
var
  vR, vC: Integer;
  vS: string;
begin
  inherited ToXml(ANode);

  vS := IntToStr(FColWidths[0]);
  for vC := 1 to FColWidths.Count - 1 do  // ���б�׼���
    vS := vS + ',' + IntToStr(FColWidths[vC]);

  ANode.Attributes['bordervisible'] := FBorderVisible;
  ANode.Attributes['borderwidth'] := FBorderWidth;
  ANode.Attributes['row'] := FRows.Count;
  ANode.Attributes['col'] := FColWidths.Count;
  ANode.Attributes['colwidth'] := vS;
  ANode.Attributes['link'] := '';

  for vR := 0 to FRows.Count - 1 do  // ��������
    FRows[vR].ToXml(ANode.AddChild('row'));
end;

procedure THCTableItem.TraverseItem(const ATraverse: TItemTraverse);
var
  vR, vC: Integer;
begin
  for vR := 0 to FRows.Count - 1 do
  begin
    if ATraverse.Stop then Break;

    for vC := 0 to FColWidths.Count - 1 do
    begin
      if ATraverse.Stop then Break;

      if Cells[vR, vC].CellData <> nil then
        Cells[vR, vC].CellData.TraverseItem(ATraverse);
    end;
  end;
end;

procedure THCTableItem.Undo_ColResize(const ACol, AOldWidth,
  ANewWidth: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vColSizeUndoData: THCColSizeUndoData;
begin
  vUndoList := GetSelfUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    SelfUndo_New;
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vColSizeUndoData := THCColSizeUndoData.Create;
      vColSizeUndoData.Col := ACol;
      vColSizeUndoData.OldWidth := AOldWidth;
      vColSizeUndoData.NewWidth := ANewWidth;

      vUndo.Data := vColSizeUndoData;
    end;
  end;
end;

procedure THCTableItem.Undo_MergeCells;
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vMirrorUndoData: THCMirrorUndoData;
begin
  vUndoList := GetSelfUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    SelfUndo_New;
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vMirrorUndoData := THCMirrorUndoData.Create;
      Self.SaveToStream(vMirrorUndoData.Stream);

      vUndo.Data := vMirrorUndoData;
    end;
  end;
end;

procedure THCTableItem.Undo_RowResize(const ARow, AOldHeight,
  ANewHeight: Integer);
var
  vUndo: THCUndo;
  vUndoList: THCUndoList;
  vRowSizeUndoData: THCRowSizeUndoData;
begin
  vUndoList := GetSelfUndoList;
  if Assigned(vUndoList) and vUndoList.Enable then
  begin
    SelfUndo_New;
    vUndo := vUndoList.Last;
    if vUndo <> nil then
    begin
      vRowSizeUndoData := THCRowSizeUndoData.Create;
      vRowSizeUndoData.Row := ARow;
      vRowSizeUndoData.OldHeight := AOldHeight;
      vRowSizeUndoData.NewHeight := ANewHeight;

      vUndo.Data := vRowSizeUndoData;
    end;
  end;
end;

function THCTableItem.WantKeyDown(const Key: Word;
  const Shift: TShiftState): Boolean;
begin
  Result := True;
end;

function THCTableItem.ActiveDataResizing: Boolean;
begin
  Result := False;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectedResizing;
end;

procedure THCTableItem.AdjustCellRange(const AStartRow, AStartCol: Integer;
  var AEndRow, AEndCol: Integer);
var
  vR, vC, vLastRow, vLastCol, vDestRow, vDestCol: Integer;
  vCell: THCTableCell;
begin
  // ������ʼ��Ԫ���ѡ�н���ȷ���ľ�����Ч��Χ
  vLastRow := AEndRow;
  vLastCol := AEndCol;
  for vR := AStartRow to AEndRow do
  begin
    for vC := AStartCol to AEndCol do
    begin
      vCell := FRows[vR].Cols[vC];
      if (vCell.RowSpan > 0) or (vCell.ColSpan > 0) then
      begin
        GetDestCell(vR, vC, vDestRow, vDestCol);
        vCell := FRows[vDestRow].Cols[vDestCol];
        vDestRow := vDestRow + vCell.RowSpan;
        vDestCol := vDestCol + vCell.ColSpan;
        if vLastRow < vDestRow then
          vLastRow := vDestRow;
        if vLastCol < vDestCol then
          vLastCol := vDestCol;
      end;
    end;
  end;

  AEndRow := vLastRow;
  AEndCol := vLastCol;
end;

procedure THCTableItem.ApplySelectParaStyle(const AStyle: THCStyle;
  const AMatchStyle: THCParaMatch);
var
  vR, vC: Integer;
  vData: THCTableCellData;
begin
  inherited ApplySelectParaStyle(AStyle, AMatchStyle);

  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    if FSelectCellRang.EndRow >= 0 then  // ��ѡ������У�˵��ѡ�в���ͬһ��Ԫ��
    begin
      for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          vData := Cells[vR, vC].CellData;
          if Assigned(vData) then
          begin
            if Self.SizeChanged then  // �������¸�ʽ����CellData���ø�ʽ����
            begin
              vData.BeginFormat;
              try
                vData.ApplySelectParaStyle(AMatchStyle);
              finally
                vData.EndFormat(False);
              end;
            end
            else
            begin
              vData.ApplySelectParaStyle(AMatchStyle);
              Self.SizeChanged := vData.FormatHeightChange or vData.FormatDrawItemChange;
            end;
          end;
        end;
      end;
    end
    else  // ��ͬһ��Ԫ��
    begin
      vData := GetEditCell.CellData;
      vData.ApplySelectParaStyle(AMatchStyle);
      Self.SizeChanged := vData.FormatHeightChange or vData.FormatDrawItemChange;
    end;

    FLastChangeFormated := not Self.SizeChanged;
  end
  else
    Self.ParaNo := AMatchStyle.GetMatchParaNo(OwnerData.Style, Self.ParaNo);
end;

procedure THCTableItem.ApplySelectTextStyle(const AStyle: THCStyle; const AMatchStyle: THCStyleMatch);
var
  vR, vC: Integer;
  vData: THCTableCellData;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    vData := GetEditCell.CellData;
    vData.ApplySelectTextStyle(AMatchStyle);
    Self.SizeChanged := vData.FormatHeightChange or vData.FormatDrawItemChange;
  end
  else
  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
    begin
      { TODO -jingtong : ����Ԫ��SelectComplateʱ������ȫ��Ӧ����ʽ }
      for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
      begin
        vData := Cells[vR, vC].CellData;
        if Assigned(vData) then
        begin
          if Self.SizeChanged then  // �������¸�ʽ����CellData���ø�ʽ����
          begin
            vData.BeginFormat;
            try
              vData.ApplySelectTextStyle(AMatchStyle);
            finally
              vData.EndFormat(False);
            end;
          end
          else
          begin
            vData.ApplySelectTextStyle(AMatchStyle);
            Self.SizeChanged := vData.FormatHeightChange or vData.FormatDrawItemChange;
          end;
        end;
      end;
    end;
  end;

  FLastChangeFormated := not Self.SizeChanged;
end;

procedure THCTableItem.Assign(Source: THCCustomItem);
var
  vR, vC: Integer;
  vSrcTable: THCTableItem;
begin
  // ���豣֤�С�������һ��
  inherited Assign(Source);

  vSrcTable := Source as THCTableItem;

  FBorderVisible := vSrcTable.BorderVisible;
  FBorderWidth := vSrcTable.BorderWidth;

  for vC := 0 to Self.ColCount - 1 do
    FColWidths[vC] := vSrcTable.FColWidths[vC];

  for vR := 0 to Self.RowCount - 1 do
  begin
    FRows[vR].AutoHeight := vSrcTable.Rows[vR].AutoHeight;
    FRows[vR].Height := vSrcTable.Rows[vR].Height;

    for vC := 0 to Self.ColCount - 1 do
    begin
      Self.Cells[vR, vC].Width := FColWidths[vC];
      Self.Cells[vR, vC].RowSpan := vSrcTable.Cells[vR, vC].RowSpan;
      Self.Cells[vR, vC].ColSpan := vSrcTable.Cells[vR, vC].ColSpan;
      Self.Cells[vR, vC].BackgroundColor := vSrcTable.Cells[vR, vC].BackgroundColor;
      Self.Cells[vR, vC].AlignVert := vSrcTable.Cells[vR, vC].AlignVert;
      Self.Cells[vR, vC].BorderSides := vSrcTable.Cells[vR, vC].BorderSides;

      if vSrcTable.Cells[vR, vC].CellData <> nil then
        Self.Cells[vR, vC].CellData.AddData(vSrcTable.Cells[vR, vC].CellData)
      else
      begin
        Self.Cells[vR, vC].CellData.Free;
        Self.Cells[vR, vC].CellData := nil;
      end;
    end;
  end;
end;

function THCTableItem.GetActiveData: THCCustomData;
var
  vCell: THCTableCell;
begin
  Result := nil;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.GetTopLevelData;
end;

function THCTableItem.GetActiveDrawItem: THCCustomDrawItem;
var
  vCellData: THCTableCellData;
begin
  Result := nil;
  vCellData := GetActiveData as THCTableCellData;
  if vCellData <> nil then
    Result := vCellData.GetTopLevelDrawItem;
end;

function THCTableItem.GetActiveDrawItemCoord: TPoint;
var
  vCell: THCTableCell;
  vPt: TPoint;
begin
  Result := Point(0, 0);
  vCell := GetEditCell;
  if vCell <> nil then
  begin
    Result := vCell.CellData.GetActiveDrawItemCoord;
    vPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Result.X := Result.X + vPt.X + FCellHPadding;
    Result.Y := Result.Y + vPt.Y + FCellVPadding;
  end;
end;

function THCTableItem.GetActiveItem: THCCustomItem;
var
  vCell: THCTableCell;
begin
  Result := Self;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.GetTopLevelItem;
end;

procedure THCTableItem.GetCaretInfo(var ACaretInfo: THCCaretInfo);
var
  i, vTop, vBottom, vRow, vCol: Integer;
  vPos: TPoint;
  vCaretCell: THCTableCell;
begin
  if OwnerData.Style.UpdateInfo.Draging then  // ��ק
  begin
    vRow := FMouseMoveRow;
    vCol := FMouseMoveCol;
  end
  else  // ����ק
  begin
    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;
  end;

  if vRow < 0 then  // û�ڱ�����棬��ǰ������
  begin
    if FOutsideInfo.Row >= 0 then  // ǰ�������Ӧ����
    begin
      if FOutsideInfo.Leftside then  // �����
        ACaretInfo.X := ACaretInfo.X - 2;  // Ϊʹ�������ԣ�����ƫ��2

      vTop := 0;
      for i := FPageBreaks.Count - 1 downto 0 do  // �ҹ�궥��λ��
      begin
        if FPageBreaks[i].Row <= FOutsideInfo.Row then  // ��ǰ��ǰ���ҳ��
        begin
          if FPageBreaks[i].PageIndex = ACaretInfo.PageIndex - 1 then  // ǰ���ҳ�����ǵ�ǰҳǰһҳ
          begin
            vTop := FPageBreaks[i].BreakBottom;  // ��ҳ�ײ�λ��
            Break;
          end;
        end;
      end;

      vBottom := Self.Height;
      for i := 0 to FPageBreaks.Count - 1 do  // �ҹ��ײ�λ��
      begin
        if FPageBreaks[i].Row >= FOutsideInfo.Row then  // ��ǰ�к����ҳ��
        begin
          if FPageBreaks[i].PageIndex = ACaretInfo.PageIndex then  // ��ҳ�ǵ�ǰҳ
          begin
            vBottom := FPageBreaks[i].BreakSeat;  // ��ҳ����λ��
            Break;
          end;
        end;
      end;

      ACaretInfo.Y := ACaretInfo.Y + vTop;
      ACaretInfo.Height := vBottom - vTop;
    end
    else
      ACaretInfo.Visible := False;

    Exit;
  end
  else
    vCaretCell := Cells[vRow, vCol];

  if OwnerData.Style.UpdateInfo.Draging then  // ��ק
  begin
    if (vCaretCell.CellData.MouseMoveItemNo < 0)
      or (vCaretCell.CellData.MouseMoveItemOffset < 0)
    then
    begin
      ACaretInfo.Visible := False;
      Exit;
    end;

    vCaretCell.GetCaretInfo(vCaretCell.CellData.MouseMoveItemNo,
      vCaretCell.CellData.MouseMoveItemOffset, ACaretInfo);
  end
  else  // ����ק
  begin
    if (vCaretCell.CellData.SelectInfo.StartItemNo < 0)
      or (vCaretCell.CellData.SelectInfo.StartItemOffset < 0)
    then
    begin
      ACaretInfo.Visible := False;
      Exit;
    end;

    vCaretCell.GetCaretInfo(vCaretCell.CellData.SelectInfo.StartItemNo,
      vCaretCell.CellData.SelectInfo.StartItemOffset, ACaretInfo);
  end;

  vPos := GetCellPostion(vRow, vCol);
  ACaretInfo.X := vPos.X + ACaretInfo.X + FCellHPadding;
  ACaretInfo.Y := vPos.Y + ACaretInfo.Y + FCellVPadding;
end;

{ TSelectCellRang }

constructor TSelectCellRang.Create;
begin
  Initialize;
end;

function TSelectCellRang.EditCell: Boolean;
begin
  Result := (FStartRow >= 0) and (FEndRow < 0);  // ������SameRow��SameCol����ݣ�
end;

procedure TSelectCellRang.Initialize;
begin
  FStartRow := -1;
  FStartCol := -1;
  FEndRow := -1;
  FEndCol := -1;
end;

function TSelectCellRang.SameCol: Boolean;
begin
  Result := (FStartCol >= 0) and (FStartCol = FEndCol);
end;

function TSelectCellRang.SameRow: Boolean;
begin
  Result := (FStartRow >= 0) and (FStartRow = FEndRow);
end;

function TSelectCellRang.SelectExists: Boolean;
begin
  Result := (FStartRow >= 0) and (FEndRow >= 0);  // ��ʱû���õ��˷���
end;

{ TColCross }

constructor TColCross.Create;
begin
  inherited;
  Col := -1;
  DrawItemNo := -1;
  VDrawOffset := 0;
  //HeightInc := 0;
  //MergeSrc := False;
end;

{ THCTableRows }

procedure THCTableRows.Notify(const Value: THCTableRow;
  Action: TCollectionNotification);
begin
  inherited;
  if Action = TCollectionNotification.cnAdded then
  begin
    if Assigned(FOnRowAdd) then
      FOnRowAdd(Value);
  end;
end;

end.
