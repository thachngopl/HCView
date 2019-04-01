{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  HCView���빫����Ԫ                   }
{                                                       }
{*******************************************************}

unit HCCommon;

interface

{$I HCView.inc}

uses
  Windows, Controls, Classes, Graphics, HCStyle;

const
  HC_TEXTMAXSIZE = 4294967295;
  HC_EXCEPTION = 'HC�쳣��';
  HCS_EXCEPTION_NULLTEXT = HC_EXCEPTION + '�ı�Item�����ݳ���Ϊ�յ������';
  HCS_EXCEPTION_TEXTOVER = HC_EXCEPTION + 'TextItem�����ݳ������������ֽ���4294967295��';
  HCS_EXCEPTION_MEMORYLESS = HC_EXCEPTION + '����ʱû�����뵽�㹻���ڴ棡';
  //HCS_EXCEPTION_UNACCEPTDATATYPE = HC_EXCEPTION + '���ɽ��ܵ��������ͣ�';
  HCS_EXCEPTION_STRINGLENGTHLIMIT = HC_EXCEPTION + '�˰汾��֧��������������ʽ�ַ�������65535��';
  HCS_EXCEPTION_VOIDSOURCECELL = HC_EXCEPTION + 'Դ��Ԫ���޷��ٻ�ȡԴ��Ԫ��';
  HCS_EXCEPTION_TIMERRESOURCEOUTOF = HC_EXCEPTION + '��װ��ʱ������Դ���㣡';

  HC_EXT = '.hcf';
  HC_PROGRAMLANGUAGE = 1;  // 1�ֽڱ�ʾʹ�õı������ 1:delphi, 2:C#, 3:VC++, 4:HTML5

  {1.3 ֧�ָ������󱣴�Ͷ�ȡ(δ�������¼���)
   1.4 ֧�ֱ��Ԫ��߿���ʾ���Եı���Ͷ�ȡ
   1.5 �ع��м��ļ��㷽ʽ
   1.6 EditItem���ӱ߿�����
   1.7 �������ع�����м��Ĵ洢
   1.8 �����˶���ʽ��ֱ������ʽ�Ĵ洢
   1.9 �ع�����ɫ�Ĵ洢��ʽ�Ա��ڼ��������������ɵ��ļ�
   2.0 ImageItem��ͼ��ʱ����ͼ�����ݴ�С�Ĵ洢�Լ��ݲ�ͬ����ͼ�����ݵĴ洢��ʽ
       �ļ�����ʱ���������ֱ���������ɵı�ʶ
   2.1 GifImage�����ȡ���ü����������Եķ�ʽ
   2.2 ���Ӷ������Ĵ洢
   2.3 ������ע�ı���Ͷ�ȡ
  }

  HC_FileVersion = '2.3';
  HC_FileVersionInt = 23;

  TabCharWidth = 28;  // Ĭ��Tab���(���) 14 * 2��
  LineSpaceMin = 8;  // �м����Сֵ
  PagePadding = 20;  // ��ҳ����ʾʱ֮��ļ��
  PMSLineHeight = 24;  // ��д��Χ�ߵĳ���
  AnnotationWidth = 200;  // ��ע��ʾ������
  AnnotateBKColor = $00D5D5FF;
  AnnotateBKActiveColor = $00A8A8FF;
  HyperTextColor = $00C16305;
  HCTransparentColor = clNone;  // ͸��ɫ
  /// <summary> ���������׵��ַ� </summary>
  DontLineFirstChar = '`-=[]\;,./~!@#$%^&*()_+{}|:"<>?�����������ܣ���������������������������������������������������������';
  /// <summary> ��������β���ַ� </summary>
  DontLineLastChar = '/\�ܡ���';

  HCBoolText: array [Boolean] of Char = ('0', '1');

type
  THCProcedure = reference to procedure();
  THCFunction = reference to function(): Boolean;

  TPageOrientation = (cpoPortrait, cpoLandscape);  // ֽ�ŷ������񡢺���

  TExpressArea = (ceaNone, ceaLeft, ceaTop, ceaRight, ceaBottom);  // ��ʽ�����򣬽��������������Ҹ�ʽ��

  TBorderSide = (cbsLeft, cbsTop, cbsRight, cbsBottom, cbsLTRB, cbsRTLB);
  TBorderSides = set of TBorderSide;

  THCViewModel = (
    vmPage,  // ҳ����ͼ����ʾҳü��ҳ��
    vmWeb  // Web��ͼ������ʾҳü��ҳ��
  );

  TSectionArea = (saHeader, saPage, saFooter);  // ��ǰ��������ĵ���һ����
  TSectionAreas = set of TSectionArea;  // ����ʱ���ļ���������

  TCharType = (
    jctBreak,  //  �ضϵ�
    jctHZ,  // ����
    jctZM,  // �����ĸ
    //jctCNZM,  // ȫ����ĸ
    jctSZ,  // �������
    //jctCNSZ,  // ȫ������
    jctFH  // ��Ƿ���
    //jctCNFH   // ȫ�Ƿ���
    );

  TPaperSize = (psCustom, ps4A0, ps2A0, psA0, psA1, psA2,
    psA3, psA4, psA5, psA6, psA7, psA8,
    psA9, psA10, psB0, psB1, psB2, psB3,
    psB4, psB5, psB6, psB7, psB8, psB9,
    psB10, psC0, psC1, psC2, psC3, psC4,
    psC5, psC6, psC7, psC8, psC9, psC10,
    psLetter, psLegal, psLedger, psTabloid,
    psStatement, psQuarto, psFoolscap, psFolio,
    psExecutive, psMonarch, psGovernmentLetter,
    psPost, psCrown, psLargePost, psDemy,
    psMedium, psRoyal, psElephant, psDoubleDemy,
    psQuadDemy, psIndexCard3_5, psIndexCard4_6,
    psIndexCard5_8, psInternationalBusinessCard,
    psUSBusinessCard, psEmperor, psAntiquarian,
    psGrandEagle, psDoubleElephant, psAtlas,
    psColombier, psImperial, psDoubleLargePost,
    psPrincess, psCartridge, psSheet, psHalfPost,
    psDoublePost, psSuperRoyal, psCopyDraught,
    psPinchedPost, psSmallFoolscap, psBrief, psPott,
    psPA0, psPA1, psPA2, psPA3, psPA4, psPA5,
    psPA6, psPA7, psPA8, psPA9, psPA10, psF4,
    psA0a, psJISB0, psJISB1, psJISB2, psJISB3,
    psJISB4, psJISB5, psJISB6, psJISB7, psJISB8,
    psJISB9, psJISB10, psJISB11, psJISB12,
    psANSI_A, psANSI_B, psANSI_C, psANSI_D,
    psANSI_E, psArch_A, psArch_B, psArch_C,
    psArch_D, psArch_E, psArch_E1,
    ps16K, ps32K);

  THCCaretInfo = record
    X, Y, Height, PageIndex: Integer;
    Visible: Boolean;
  end;

  {$IFNDEF DELPHIXE}
  THCPoint = record helper for TPoint
  public
    procedure Offset(const DX, DY : Integer); overload;
    procedure Offset(const Point: TPoint); overload;
  end;

  THCRect = record helper for TRect
  protected
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
    function GetLocation: TPoint;
    procedure SetLocation(const Point: TPoint);
  public
    procedure Offset(const DX, DY: Integer); overload;
    procedure Offset(const Point: TPoint); overload;
    procedure Inflate(const DX, DY: Integer);
    property Height: Integer read GetHeight write SetHeight;
    property Width: Integer read GetWidth write SetWidth;
    property Location: TPoint read GetLocation write SetLocation;
  end;
  {$ENDIF}

  TMarkType = (cmtBeg, cmtEnd);

  THCCaret = Class(TObject)
  private
    FHeight: Integer;
    FOwnHandle: THandle;
  protected
    procedure SetHeight(const Value: Integer);
  public
    X, Y: Integer;
    //Visible: Boolean;
    constructor Create(const AHandle: THandle);
    destructor Destroy; override;
    procedure ReCreate;
    procedure Show(const AX, AY: Integer); overload;
    procedure Show; overload;
    procedure Hide;
    property Height: Integer read FHeight write SetHeight;
  end;

  function SwapBytes(AValue: Word): Word;
  function IsKeyPressWant(const AKey: Char): Boolean;
  function IsKeyDownWant(const AKey: Word): Boolean;

  /// <summary> Ч�ʸ��ߵķ����ַ����ַ���λ�ú��� </summary>
  function PosCharHC(const AChar: Char; const AStr: string{; const Offset: Integer = 1}): Integer;

  /// <summary> �����ַ����� </summary>
  function GetUnicodeCharType(const AChar: Char): TCharType;

  /// <summary>
  /// ����ָ��λ�����ַ����ĸ��ַ�����(0����һ��ǰ��)
  /// </summary>
  /// <param name="ACanvas"></param>
  /// <param name="AText"></param>
  /// <param name="X"></param>
  /// <returns></returns>
  function GetCharOffsetAt(const ACanvas: TCanvas; const AText: string; const X: Integer): Integer;

  // ���ݺ��ִ�С��ȡ�������ִ�С
  function GetFontSize(const AFontSize: string): Single;
  function GetFontSizeStr(AFontSize: Single): string;
  function GetPaperSizeStr(APaperSize: Integer): string;

  function GetVersionAsInteger(const AVersion: string): Integer;
  function GetBorderSidePro(const ABorderSides: TBorderSides): string;
  procedure SetBorderSideByPro(const AValue: string; var ABorderSides: TBorderSides);

  /// <summary> ���泤��С��65536���ֽڵ��ַ������� </summary>
  procedure HCSaveTextToStream(const AStream: TStream; const S: string);
  procedure HCLoadTextFromStream(const AStream: TStream; var S: string);

  procedure HCSaveColorToStream(const AStream: TStream; const AColor: TColor);
  procedure HCLoadColorFromStream(const AStream: TStream; var AColor: TColor);

  /// <summary> �����ļ���ʽ���汾 </summary>
  procedure _SaveFileFormatAndVersion(const AStream: TStream);
  /// <summary> ��ȡ�ļ���ʽ���汾 </summary>
  procedure _LoadFileFormatAndVersion(const AStream: TStream;
    var AFileFormat: string; var AVersion: Word; var ALang: Byte);

  {$IFDEF DEBUG}
  procedure DrawDebugInfo(const ACanvas: TCanvas; const ALeft, ATop: Integer; const AInfo: string);
  {$ENDIF}

var
  GCursor: TCursor;
  HC_FILEFORMAT, CF_HTML, CF_RTF: Word;

implementation

uses
  SysUtils;

{$IFDEF DEBUG}
procedure DrawDebugInfo(const ACanvas: TCanvas; const ALeft, ATop: Integer; const AInfo: string);
var
  vFont: TFont;
begin
  vFont := TFont.Create;
  try
    vFont.Assign(ACanvas.Font);
    ACanvas.Font.Color := clGray;
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [];
    ACanvas.Font.Name := 'Courier New';
    ACanvas.Brush.Style := bsClear;

    ACanvas.TextOut(ALeft, ATop, AInfo);
  finally
    ACanvas.Font.Assign(vFont);
    FreeAndNil(vFont);
  end;
end;
{$ENDIF}

function SwapBytes(AValue: Word): Word;
begin
  Result := (AValue shr 8) or Word(AValue shl 8);
end;

procedure HCSaveTextToStream(const AStream: TStream; const S: string);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  vBuffer := BytesOf(S);
  if System.Length(vBuffer) > MAXWORD then
    raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
  vSize := System.Length(vBuffer);
  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure HCLoadTextFromStream(const AStream: TStream; var S: string);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    S := StringOf(vBuffer);
  end
  else
    S := '';
end;

function GetUnicodeCharType(const AChar: Char): TCharType;
begin
  case Cardinal(AChar) of
    $2E80..$2EF3,  // ������չ 115
    $2F00..$2FD5,  // �������� 214
    $2FF0..$2FFB,  // ���ֽṹ 12
    $3007,  // �� 1
    $3105..$312F,  // ����ע�� 43
    $31A0..$31BA,  // ע����չ 22
    $31C0..$31E3,  // ���ֱʻ� 36
    $3400..$4DB5,  // ��չA 6582��
    $4E00..$9FA5,  // �������� 20902��
    $9FA6..$9FEF,  // �������ֲ��� 74��
    $E400..$E5E8,  // ������չ 452
    $E600..$E6CF,  // PUA���� 207
    $E815..$E86F,  // PUA(GBK)���� 81
    $F900..$FAD9,  // ���ݺ��� 477
    $20000..$2A6D6, // ��չB 42711��
    $2A700..$2B734,  // ��չC 4149
    $2B740..$2B81D,  // ��չD 222
    $2B820..$2CEA1,  // ��չE 5762
    $2CEB0..$2EBE0,  // ��չF 7473
    $2F800..$2FA1D  // ������չ 542
      : Result := jctHZ;  // ����

    $F00..$FFF: Result := jctHZ;  // ����

    $1800..$18AF: Result := jctHZ;  // �ɹ��ַ�

    $21..$2F,  // !"#$%&'()*+,-./
    $3A..$40,  // :;<=>?@
    $5B..$60,  // [\]^_`
    $7B..$7E,   // {|}~
    $FFE0  // ��
      : Result := jctFH;

    //$FF01..$FF0F,  // ������������������������������

    $30..$39: Result := jctSZ;  // 0..9

    $41..$5A, $61..$7A: Result := jctZM;  // A..Z, a..z
  else
    Result := jctBreak;
  end;
end;

function IsKeyPressWant(const AKey: Char): Boolean;
begin
  Result := AKey in [#32..#126];  // <#32��ASCII������ #127��ASCII DEL
end;

function IsKeyDownWant(const AKey: Word): Boolean;
begin
  Result := AKey in [VK_BACK, VK_DELETE, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_RETURN,
    VK_HOME, VK_END, VK_TAB];
end;

function PosCharHC(const AChar: Char; const AStr: string{; const Offset: Integer = 1}): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AStr) do
  begin
    if AChar = AStr[i] then
    begin
      Result := i;
      Exit
    end;
  end;
end;

function GetFontSize(const AFontSize: string): Single;
begin
  if AFontSize = '����' then Result := 42
  else
  if AFontSize = 'С��' then Result := 36
  else
  if AFontSize = 'һ��' then Result := 26
  else
  if AFontSize = 'Сһ' then Result := 24
  else
  if AFontSize = '����' then Result := 22
  else
  if AFontSize = 'С��' then Result := 18
  else
  if AFontSize = '����' then Result := 16
  else
  if AFontSize = 'С��' then Result := 15
  else
  if AFontSize = '�ĺ�' then Result := 14
  else
  if AFontSize = 'С��' then Result := 12
  else
  if AFontSize = '���' then Result := 10.5
  else
  if AFontSize = 'С��' then Result := 9
  else
  if AFontSize = '����' then Result := 7.5
  else
  if AFontSize = 'С��' then Result := 6.5
  else
  if AFontSize = '�ߺ�' then Result := 5.5
  else
  if AFontSize = '�˺�' then Result := 5
  else
  if not TryStrToFloat(AFontSize, Result) then
    raise Exception.Create(HC_EXCEPTION + '�����ֺŴ�С�����޷�ʶ���ֵ��' + AFontSize);
end;

function GetFontSizeStr(AFontSize: Single): string;
begin
  if AFontSize = 42 then Result := '����'
  else
  if AFontSize = 36 then Result := 'С��'
  else
  if AFontSize = 26 then Result := 'һ��'
  else
  if AFontSize = 24 then Result := 'Сһ'
  else
  if AFontSize = 22 then Result := '����'
  else
  if AFontSize = 18 then Result := 'С��'
  else
  if AFontSize = 16 then Result := '����'
  else
  if AFontSize = 15 then Result := 'С��'
  else
  if AFontSize = 14 then Result := '�ĺ�'
  else
  if AFontSize = 12 then Result := 'С��'
  else
  if AFontSize = 10.5 then Result := '���'
  else
  if AFontSize = 9 then Result := 'С��'
  else
  if AFontSize = 7.5 then Result := '����'
  else
  if AFontSize = 6.5 then Result := 'С��'
  else
  if AFontSize = 5.5 then Result := '�ߺ�'
  else
  if AFontSize = 5 then Result := '�˺�'
  else
    Result := FormatFloat('0.#', AFontSize);
end;

function GetPaperSizeStr(APaperSize: Integer): string;
begin
  case APaperSize of
    DMPAPER_A3: Result := 'A3';
    DMPAPER_A4: Result := 'A4';
    DMPAPER_A5: Result := 'A5';
    DMPAPER_B5: Result := 'B5';
  else
    Result := '�Զ���';
  end;
end;

function GetVersionAsInteger(const AVersion: string): Integer;
var
  vsVer: string;
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AVersion) do
  begin
    if AVersion[i] in ['0'..'9'] then
      vsVer := vsVer + AVersion[i];
  end;
  Result := StrToInt(vsVer);
end;

function GetBorderSidePro(const ABorderSides: TBorderSides): string;
begin
  if cbsLeft in ABorderSides then
    Result := 'left';

  if cbsTop in ABorderSides then
  begin
    if Result <> '' then
      Result := Result + ',top'
    else
      Result := 'top';
  end;

  if cbsRight in ABorderSides then
  begin
    if Result <> '' then
      Result := Result + ',right'
    else
      Result := 'right';
  end;

  if cbsBottom in ABorderSides then
  begin
    if Result <> '' then
      Result := Result + ',bottom'
    else
      Result := 'bottom';
  end;

  if cbsLTRB in ABorderSides then
  begin
    if Result <> '' then
      Result := Result + ',ltrb'
    else
      Result := 'ltrb';
  end;

  if cbsRTLB in ABorderSides then
  begin
    if Result <> '' then
      Result := Result + ',rtlb'
    else
      Result := 'rtlb';
  end;
end;

procedure SetBorderSideByPro(const AValue: string; var ABorderSides: TBorderSides);
var
  vList: TStringList;
  i: Integer;
begin
  ABorderSides := [];
  vList := TStringList.Create;
  try
    vList.Delimiter := ',';
    vList.DelimitedText := AValue;
    for i := 0 to vList.Count - 1 do
    begin
      if vList[i] = 'left' then
        Include(ABorderSides, cbsLeft)
      else
      if vList[i] = 'top' then
        Include(ABorderSides, cbsTop)
      else
      if vList[i] = 'right' then
        Include(ABorderSides, cbsRight)
      else
      if vList[i] = 'bottom' then
        Include(ABorderSides, cbsBottom)
      else
      if vList[i] = 'ltrb' then
        Include(ABorderSides, cbsLTRB)
      else
      if vList[i] = 'rtlb' then
        Include(ABorderSides, cbsRTLB)
    end;
  finally
    FreeAndNil(vList);
  end;
end;

/// <summary> �����ļ���ʽ���汾 </summary>
procedure _SaveFileFormatAndVersion(const AStream: TStream);
var
  vS: string;
  vLang: Byte;
begin
  vS := HC_EXT;
  AStream.WriteBuffer(vS[1], Length(vS) * SizeOf(Char));
  // �汾
  vS := HC_FileVersion;
  AStream.WriteBuffer(vS[1], Length(vS) * SizeOf(Char));
  // ʹ�õı������
  vLang := HC_PROGRAMLANGUAGE;
  AStream.WriteBuffer(vLang, 1);
end;

/// <summary> ��ȡ�ļ���ʽ���汾 </summary>
procedure _LoadFileFormatAndVersion(const AStream: TStream;
  var AFileFormat: string; var AVersion: Word; var ALang: Byte);
var
  vFileVersion: string;
begin
  // �ļ���ʽ
  SetLength(AFileFormat, Length(HC_EXT));
  AStream.ReadBuffer(AFileFormat[1], Length(HC_EXT) * SizeOf(Char));

  // �汾
  SetLength(vFileVersion, Length(HC_FileVersion));
  AStream.ReadBuffer(vFileVersion[1], Length(HC_FileVersion) * SizeOf(Char));
  AVersion := GetVersionAsInteger(vFileVersion);

  if AVersion > 19 then // ʹ�õı������
    AStream.ReadBuffer(ALang, 1);
end;

procedure HCSaveColorToStream(const AStream: TStream; const AColor: TColor);
var
  vByte: Byte;
begin
  if AColor = HCTransparentColor then  // ͸��
  begin
    vByte := 0;
    AStream.WriteBuffer(vByte, 1);
    vByte := 255;
    AStream.WriteBuffer(vByte, 1);
    AStream.WriteBuffer(vByte, 1);
    AStream.WriteBuffer(vByte, 1);
  end
  else
  begin
    vByte := 255;
    AStream.WriteBuffer(vByte, 1);

    vByte := GetRValue(AColor);
    AStream.WriteBuffer(vByte, 1);

    vByte := GetGValue(AColor);
    AStream.WriteBuffer(vByte, 1);

    vByte := GetBValue(AColor);
    AStream.WriteBuffer(vByte, 1);
  end;
end;

procedure HCLoadColorFromStream(const AStream: TStream; var AColor: TColor);
var
  vA, vR, vG, vB: Byte;
begin
  AStream.ReadBuffer(vA, 1);
  AStream.ReadBuffer(vR, 1);
  AStream.ReadBuffer(vG, 1);
  AStream.ReadBuffer(vB, 1);

  if vA = 0 then
    AColor := HCTransparentColor
  else
  if vA = 255 then
    AColor := vB shl 16 + vG shl 8 + vR;
end;

function GetCharOffsetAt(const ACanvas: TCanvas; const AText: string; const X: Integer): Integer;
var
  i, vX, vCharWidth: Integer;
begin
  Result := -1;

  if X < 0 then
    Result := 0
  else
  if X > ACanvas.TextWidth(AText) then
    Result := Length(AText)
  else
  begin
    vX := 0;
    for i := 1 to Length(AText) do  { TODO : �пո�Ϊ���ַ�����Ч }
    begin
      vCharWidth := ACanvas.TextWidth(AText[i]);
      vX := vX + vCharWidth;
      if vX > X then  // ��ǰ�ַ�����λ����X��
      begin
        if vX - vCharWidth div 2 > X then  // �����ǰ�벿��
          Result := i - 1  // ��Ϊǰһ������
        else
          Result := i;
        Break;
      end;
    end;
  end;
end;

{ THCCaret }

constructor THCCaret.Create(const AHandle: THandle);
begin
  FOwnHandle := AHandle;
  CreateCaret(FOwnHandle, 0, 2, 20);
end;

destructor THCCaret.Destroy;
begin
  DestroyCaret;
  FOwnHandle := 0;
  inherited;
end;

procedure THCCaret.Hide;
begin
  HideCaret(FOwnHandle);
end;

procedure THCCaret.ReCreate;
begin
  DestroyCaret;
  CreateCaret(FOwnHandle, 0, 2, FHeight);
end;

procedure THCCaret.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    ReCreate;
  end;
end;

procedure THCCaret.Show;
begin
  Self.Show(X, Y);
end;


procedure THCCaret.Show(const AX, AY: Integer);
begin
  ReCreate;
  SetCaretPos(AX, AY);
  ShowCaret(FOwnHandle);
end;

{$IFNDEF DELPHIXE}
{ THCRect }

function THCRect.GetHeight: Integer;
begin
  Result := Self.Bottom - Self.Top;
end;

function THCRect.GetLocation: TPoint;
begin
  Result := TopLeft;
end;

function THCRect.GetWidth: Integer;
begin
  Result := Self.Right - Self.Left;
end;

procedure THCRect.Inflate(const DX, DY: Integer);
begin
  TopLeft.Offset(-DX, -DY);
  BottomRight.Offset(DX, DY);
end;

procedure THCRect.Offset(const Point: TPoint);
begin
  TopLeft.Offset(Point);
  BottomRight.Offset(Point);
end;

procedure THCRect.Offset(const DX, DY: Integer);
begin
  TopLeft.Offset(DX, DY);
  BottomRight.Offset(DX, DY);
end;

procedure THCRect.SetHeight(const Value: Integer);
begin
  Self.Bottom := Self.Top + Value;
end;

procedure THCRect.SetLocation(const Point: TPoint);
begin
  Offset(Point.X - Left, Point.Y - Top);
end;

procedure THCRect.SetWidth(const Value: Integer);
begin
  Self.Right := Self.Left + Value;
end;

{ THCPoint }

procedure THCPoint.Offset(const DX, DY: Integer);
begin
  Inc(Self.X, DX);
  Inc(Self.Y, DY);
end;

procedure THCPoint.Offset(const Point: TPoint);
begin
  Self.Offset(Point.X, Point.Y);
end;
{$ENDIF}

initialization
  if HC_FILEFORMAT = 0 then
    HC_FILEFORMAT := RegisterClipboardFormat(HC_EXT);

  if CF_HTML = 0 then
    CF_HTML := RegisterClipboardFormat('HTML Format');

  if CF_RTF = 0 then
    CF_RTF := RegisterClipboardFormat('Rich Text Format');

end.
