{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                �ı����HCItem���൥Ԫ                 }
{                                                       }
{*******************************************************}

unit HCTextItem;

interface

uses
  Windows, Classes, SysUtils, Graphics, HCStyle, HCItem, HCXml;

type
  THCTextItemClass = class of THCTextItem;

  THCTextItem = class(THCCustomItem)
  private
    FText, FHyperLink: string;
  protected
    function GetText: string; override;
    procedure SetText(const Value: string); override;
    function GetHyperLink: string; override;
    procedure SetHyperLink(const Value: string); override;
    function GetLength: Integer; override;
  public
    constructor CreateByText(const AText: string); virtual;
    procedure Assign(Source: THCCustomItem); override;
    function BreakByOffset(const AOffset: Integer): THCCustomItem; override;
    // ����Ͷ�ȡ
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    function ToHtml(const APath: string): string; override;
    procedure ToXml(const ANode: IHCXMLNode); override;
    procedure ParseXml(const ANode: IHCXMLNode); override;

    /// <summaryy ����һ�����ı� </summary>
    /// <param name="AStartOffs">���Ƶ���ʼλ��(����0)</param>
    /// <param name="ALength">����ʼλ�����Ƶĳ���</param>
    /// <returns>�ı�����</returns>
    function SubString(const AStartOffs, ALength: Integer): string;
  end;

var
  HCDefaultTextItemClass: THCTextItemClass = THCTextItem;

implementation

uses
  HCCommon, HCTextStyle;

{ THCTextItem }

constructor THCTextItem.CreateByText(const AText: string);
begin
  Create;  // ������� inherited Create; �����THCCustomItem��Create������TEmrTextItem����CreateByTextʱ����ִ���Լ���Create
  FText := AText;
  FHyperLink := '';
end;

procedure THCTextItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  FText := (Source as THCTextItem).Text;
end;

function THCTextItem.BreakByOffset(const AOffset: Integer): THCCustomItem;
begin
  if (AOffset >= Length) or (AOffset <= 0) then
    Result := nil
  else
  begin
    Result := inherited BreakByOffset(AOffset);
    Result.Text := Self.SubString(AOffset + 1, Length - AOffset);
    Delete(FText, AOffset + 1, Length - AOffset);  // ��ǰItem��ȥ������ַ���
  end;
end;

function THCTextItem.GetHyperLink: string;
begin
  Result := FHyperLink;
end;

function THCTextItem.GetLength: Integer;
begin
  Result := System.Length(FText);
end;

function THCTextItem.GetText: string;
begin
  Result := FText;
end;

function THCTextItem.SubString(const AStartOffs, ALength: Integer): string;
begin
  Result := Copy(FText, AStartOffs, ALength);
end;

procedure THCTextItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vDSize: DWORD;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  if AFileVersion < 11 then  // ����65536������ַ�����
  begin
    AStream.ReadBuffer(vSize, SizeOf(Word));
    vDSize := vSize;
  end
  else
    AStream.ReadBuffer(vDSize, SizeOf(DWORD));

  if vDSize > 0 then
  begin
    SetLength(vBuffer, vDSize);
    AStream.Read(vBuffer[0], vDSize);
    FText := StringOf(vBuffer);
  end;
end;

procedure THCTextItem.ParseXml(const ANode: IHCXMLNode);
begin
  inherited ParseXml(ANode);
  FHyperLink := ANode.Attributes['link'];
  FText := ANode.Text;
end;

procedure THCTextItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);
var
  vS: string;
  vBuffer: TBytes;
  vSize: DWORD;
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  vS := SubString(AStart + 1, AEnd - AStart);
  //  DWORD��С������HCSaveTextToStream(AStream, vS);
  vBuffer := BytesOf(vS);
  if System.Length(vBuffer) > HC_TEXTMAXSIZE then
    raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
  vSize := System.Length(vBuffer);
  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure THCTextItem.SetHyperLink(const Value: string);
begin
  FHyperLink := Value;
end;

procedure THCTextItem.SetText(const Value: string);
begin
  FText := Value;
end;

function THCTextItem.ToHtml(const APath: string): string;
begin
  Result := '<a class="fs' + IntToStr(StyleNo) + '">' + Text + '</a>';
end;

procedure THCTextItem.ToXml(const ANode: IHCXMLNode);
begin
  inherited ToXml(ANode);
  ANode.Attributes['link'] := FHyperLink;
  ANode.Text := Text;
end;

end.
