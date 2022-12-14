{ lclutils unit

  Copyright (C) 2005-2021 Lagunov Aleksey alexs75@yandex.ru and Lazarus team
  original conception from rx library for Delphi (c)

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit rxlclutils;

{$I rx.inc}

interface

uses
{$IFDEF WIN32}
  windows,
{$ENDIF}
  Classes, SysUtils, Graphics, Controls, Forms, LResources
  ;


const
  COLORONCOLOR = 3;
  STRETCH_DELETESCANS = COLORONCOLOR;
  PaletteMask = $02000000;

type
  TTextOrientation = (toHorizontal, toVertical90, toHorizontal180, toVertical270, toHorizontal360);

  { TRxPageMargin }

  TRxPageMargin = class(TPersistent)
  private
    FBottom: integer;
    FLeft: integer;
    FRight: integer;
    FTop: integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
  published
    property Left:integer read FLeft write FLeft default 20;
    property Top:integer read FTop write FTop default 20;
    property Right:integer read FRight write FRight default 20;
    property Bottom:integer read FBottom write FBottom default 20;
  end;

function WidthOf(R: TRect): Integer; inline;
function HeightOf(R: TRect): Integer; inline;

procedure RxFrame3D(Canvas: TCanvas; var Rect: TRect; TopColor, BottomColor: TColor;
  Width: Integer);
function DrawButtonFrame(Canvas: TCanvas; const Client: TRect;
  IsDown, IsFlat: Boolean): TRect;
function DrawButtonFrameXP(Canvas: TCanvas; const Client: TRect;
  IsDown, IsFlat: Boolean): TRect;

//Code from TAChartUtils
procedure RotateLabel(Canvas: TCanvas; x, y: Integer; const St: String; RotDegree: Integer);
procedure OutTextXY90(Canvas:TCanvas; X,Y:integer; Text:string; Orientation:TTextOrientation);

function IsForegroundTask: Boolean;
function ValidParentForm(Control: TControl): TCustomForm;
function CreateArrowBitmap:TBitmap;
function RxCreateResBitmap(const AResName:string):TCustomBitmap;
procedure RxAssignBitmap(const AGlyph: TBitmap; const AResName:string);
//function  LoadLazResBitmapImage(const ResName: string): TBitmap;

{functions from DBGrid}
function  GetWorkingCanvas(const Canvas: TCanvas): TCanvas;
procedure FreeWorkingCanvas(canvas: TCanvas);


procedure RaiseIndexOutOfBounds(Control: TControl; Items:TStrings; Index: integer);

procedure WriteTextHeader(ACanvas: TCanvas; ARect: TRect; const Text: string; Alignment: TAlignment);
//procedure DrawBitmapTransparent(Dest: TCanvas; DstX, DstY: Integer; Bitmap: TBitmap; TransparentColor: TColor);

{$IFDEF WIN32}
type
  PCursorOrIcon = ^TCursorOrIcon;
  TCursorOrIcon = packed record
    Reserved: Word;
    wType: Word;
    Count: Word;
  end;

  PIconRec = ^TIconRec;
  TIconRec = packed record
    Width: Byte;
    Height: Byte;
    Colors: Word;
    Reserved1: Word;
    Reserved2: Word;
    DIBSize: Longint;
    DIBOffset: Longint;
  end;

procedure ReadIcon(Stream: TStream; var Icon: HICON; ImageCount: Integer;
  StartOffset: Integer; const RequestedSize: TPoint; var IconSize: TPoint);
procedure OutOfResources;
{$ENDIF}

implementation
uses LCLProc, LCLIntf, LCLType, LCLStrConsts, Grids, math;

{$IFNDEF RX_USE_LAZARUS_RESOURCE}
{$R rx_lcl.res}
{$ENDIF}

{ TRxPageMargin }

procedure TRxPageMargin.AssignTo(Dest: TPersistent);
begin
  if (Dest is TRxPageMargin) then
  begin
    TRxPageMargin(Dest).FBottom:=FBottom;
    TRxPageMargin(Dest).FLeft:=FLeft;
    TRxPageMargin(Dest).FRight:=FRight;
    TRxPageMargin(Dest).FTop:=FTop;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TRxPageMargin.Create;
begin
  inherited Create;
  FBottom:=20;
  FLeft:=20;
  FRight:=20;
  FTop:=20;
end;

function WidthOf(R: TRect): Integer;
begin
  Result := R.Right - R.Left;
end;

function HeightOf(R: TRect): Integer;
begin
  Result := R.Bottom - R.Top;
end;

procedure RxFrame3D(Canvas: TCanvas; var Rect: TRect; TopColor, BottomColor: TColor;
  Width: Integer);

procedure DoRect;
var
  TopRight, BottomLeft: TPoint;
begin
  TopRight.X := Rect.Right;
  TopRight.Y := Rect.Top;
  BottomLeft.X := Rect.Left;
  BottomLeft.Y := Rect.Bottom;
  Canvas.Pen.Color := TopColor;
  Canvas.PolyLine([BottomLeft, Rect.TopLeft, TopRight]);
  Canvas.Pen.Color := BottomColor;
  Dec(BottomLeft.X);
  Canvas.PolyLine([TopRight, Rect.BottomRight, BottomLeft]);
end;

begin
  Canvas.Pen.Width := 1;
  Dec(Rect.Bottom); Dec(Rect.Right);
  while Width > 0 do
  begin
    Dec(Width);
    DoRect;
    InflateRect(Rect, -1, -1);
  end;
  Inc(Rect.Bottom); Inc(Rect.Right);
end;

function DrawButtonFrame(Canvas: TCanvas; const Client: TRect;
  IsDown, IsFlat: Boolean): TRect;
begin
  Result := Client;
  if IsDown then
  begin
    RxFrame3D(Canvas, Result, clWindowFrame, clBtnHighlight, 1);
    if not IsFlat then
      RxFrame3D(Canvas, Result, clBtnShadow, clBtnFace, 1);
  end
  else
  begin
    if IsFlat then
      RxFrame3D(Canvas, Result, clBtnHighlight, clBtnShadow, 1)
    else
    begin
      RxFrame3D(Canvas, Result, clBtnHighlight, clWindowFrame, 1);
      RxFrame3D(Canvas, Result, clBtnFace, clBtnShadow, 1);
    end;
  end;
  InflateRect(Result, -1, -1);
end;

function DrawButtonFrameXP(Canvas: TCanvas; const Client: TRect; IsDown,
  IsFlat: Boolean): TRect;
begin
  Result := Client;
  Canvas.Brush.Color := $00EFD3C6;
  Canvas.FillRect(Client);
  RxFrame3D(Canvas, Result, $00C66931, $00C66931, 1);
end;

{$IFDEF WIN32}
type
  PCheckTaskInfo = ^TCheckTaskInfo;
  TCheckTaskInfo = packed record
    FocusWnd: HWnd;
    Found: Boolean;
  end;
//function CheckTaskWindow(Window: HWnd; Data: Longint): WordBool; stdcall;
function CheckTaskWindow(Window:HWND; Data:LPARAM):WINBOOL;stdcall;
begin
  Result := True;
  if PCheckTaskInfo(Data)^.FocusWnd = Window then begin
    Result := False;
    PCheckTaskInfo(Data)^.Found := True;
  end;
end;
{$ENDIF}

function IsForegroundTask: Boolean;
{$IFDEF WIN32}
var
  Info: TCheckTaskInfo;
{$ENDIF}
begin
{$IFDEF WIN32}
  Info.FocusWnd := GetActiveWindow;
  Info.Found := False;
  EnumThreadWindows(GetCurrentThreadID, @CheckTaskWindow, Longint(@Info));
  Result := Info.Found;
{$ELSE}
  Result:=true;
{$ENDIF}
end;

function ValidParentForm(Control: TControl): TCustomForm;
begin
  Result := GetParentForm(Control);
  if Result = nil then
    raise EInvalidOperation.CreateFmt('ParentRequired %s', [Control.Name]);
end;

procedure RotateLabel(Canvas: TCanvas; x, y: Integer; const St: String; RotDegree: Integer);
var
  L:integer;
begin
  L:=Canvas.Font.Orientation;

  SetBkMode(Canvas.Handle, TRANSPARENT);

  Canvas.Font.Orientation:=RotDegree * 10;
  Canvas.TextOut(X, Y, St);

{  DrawText(ACanvas.Handle, PChar(Text), Length(Text), DrawRect,
    ALIGN_FLAGS_HEADER[Alignment]  or DT_WORDBREAK
    );}

  Canvas.Font.Orientation:=L;
end;


procedure OutTextXY90(Canvas:TCanvas; X,Y:integer; Text:string; Orientation:TTextOrientation);
{$IFDEF OLD_STYLE_TEXT_ROTATE}
var
  W,H, i,j:integer;
  Bmp:TBitmap;
begin
  if Orientation = toHorizontal then
    Canvas.TextOut(X, Y, Text)
  else
  begin
    W:=Canvas.TextWidth(Text);
    H:=Canvas.TextHeight(Text);
    Bmp:=TBitMap.Create;
    try
      Bmp.Width:=W;
      Bmp.Height:=H;
      Bmp.Canvas.Brush.Style:=bsSolid;
      Bmp.Canvas.Brush.Color:=clWhite;
      Bmp.Canvas.FillRect(Rect(0,0,W,H));
      Bmp.Canvas.Font:=Canvas.Font;
      Bmp.Canvas.TextOut(0, 0, Text);
      Canvas.Lock;
      if Orientation = toVertical90 then
      begin
        for i:=0 to W-1 do
          for j:=0 to H-1 do
            if Bmp.Canvas.Pixels[i,j]<>clWhite then
              Canvas.Pixels[(H-j)+X,i+Y]:=Bmp.Canvas.Pixels[i,j];
      end
      else
      if Orientation = toVertical270 then
      begin
        for i:=0 to W-1 do
          for j:=0 to H-1 do
            if Bmp.Canvas.Pixels[i,j]<>clWhite then
              Canvas.Pixels[j+X,(W-i)+Y]:=Bmp.Canvas.Pixels[i,j];
      end
      else
      if Orientation = toHorizontal180 then
      begin
        for i:=0 to W-1 do
          for j:=0 to H-1 do
            if Bmp.Canvas.Pixels[i,j]<>clWhite then
              Canvas.Pixels[i+X,(H-j)+Y]:=Bmp.Canvas.Pixels[i,j];
      end
      else
      if Orientation = toHorizontal360 then
      begin
        for i:=0 to W-1 do
          for j:=0 to H-1 do
            if Bmp.Canvas.Pixels[i,j]<>clWhite then
              Canvas.Pixels[(W-i)+X,j+Y]:=Bmp.Canvas.Pixels[i,j];
      end;
      Canvas.Unlock;
    finally
      Bmp.Free;
    end;
  end;
end;
{$ELSE}
const
  TextAngle: array [TTextOrientation] of integer =
      (0 {toHorizontal}, 90 {toVertical90},
       180 {toHorizontal180}, 270 {toVertical270}, 0 {toHorizontal360});
var
  W, H:integer;
begin
  W:=0;
  H:=0;
  case Orientation of
    toVertical90:
       begin
         H:=Canvas.TextWidth(Text);
       end;
    toVertical270:
       begin
         W:=Canvas.TextHeight(Text);
       end;
    toHorizontal180:
       begin
         H:=Canvas.TextHeight(Text);
         W:=Canvas.TextWidth(Text);
       end;
  end;
  RotateLabel(Canvas, X+W, Y+H, Text, TextAngle[Orientation]);
end;
{$ENDIF}


{$IFDEF WIN32}
function CreateIcon(hInstance: HINST; nWidth, nHeight: Integer;
  cPlanes, cBitsPixel: Byte; lpbANDbits, lpbXORbits: Pointer): HICON; stdcall; external user32 name 'CreateIcon';

procedure GDIError;
var
  ErrorCode: Integer;
  Buf: array [Byte] of Char;
begin
  ErrorCode := GetLastError;
  if (ErrorCode <> 0) and (FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil,
    ErrorCode, LOCALE_USER_DEFAULT, Buf, sizeof(Buf), nil) <> 0) then
    raise EOutOfResources.Create(Buf)
  else
    OutOfResources;
end;

function DupBits(Src: HBITMAP; Size: TPoint; Mono: Boolean): HBITMAP;
var
  DC, Mem1, Mem2: HDC;
  Old1, Old2: HBITMAP;
  Bitmap: Windows.TBitmap;
begin
  Mem1 := CreateCompatibleDC(0);
  Mem2 := CreateCompatibleDC(0);

  try
    GetObject(Src, SizeOf(Bitmap), @Bitmap);
    if Mono then
      Result := CreateBitmap(Size.X, Size.Y, 1, 1, nil)
    else
    begin
      DC := GetDC(0);
      if DC = 0 then GDIError;
      try
        Result := CreateCompatibleBitmap(DC, Size.X, Size.Y);
        if Result = 0 then GDIError;
      finally
        ReleaseDC(0, DC);
      end;
    end;

    if Result <> 0 then
    begin
      Old1 := SelectObject(Mem1, Src);
      Old2 := SelectObject(Mem2, Result);

      StretchBlt(Mem2, 0, 0, Size.X, Size.Y, Mem1, 0, 0, Bitmap.bmWidth,
        Bitmap.bmHeight, SrcCopy);
      if Old1 <> 0 then SelectObject(Mem1, Old1);
      if Old2 <> 0 then SelectObject(Mem2, Old2);
    end;
  finally
    DeleteDC(Mem1);
    DeleteDC(Mem2);
  end;
end;

function GDICheck(Value: Integer): Integer;
begin
  if Value = 0 then GDIError;
  Result := Value;
end;

function GetDInColors(BitCount: Word): Integer;
begin
  case BitCount of
    1, 4, 8: Result := 1 shl BitCount;
  else
    Result := 0;
  end;
end;

function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
begin
  Dec(Alignment);
  Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
  Result := Result div 8;
end;

procedure TwoBitsFromDIB(var BI: TBitmapInfoHeader; var XorBits, AndBits: HBITMAP;
  const IconSize: TPoint);
type
  PLongArray = ^TLongArray;
  TLongArray = array[0..1] of Longint;
var
  Temp: HBITMAP;
  NumColors: Integer;
  DC: HDC;
  Bits: Pointer;
  Colors: PLongArray;
begin
  with BI do
  begin
    biHeight := biHeight shr 1; { Size in record is doubled }
    biSizeImage := BytesPerScanline(biWidth, biBitCount, 32) * biHeight;
    NumColors := GetDInColors(biBitCount);
  end;
  DC := GetDC(0);
  if DC = 0 then OutOfResources;
  try
    Bits := Pointer(Longint(@BI) + SizeOf(BI) + NumColors * SizeOf(TRGBQuad));
    Temp := GDICheck(CreateDIBitmap(DC, BI, CBM_INIT, Bits, PBitmapInfo(@BI)^, DIB_RGB_COLORS));
    try
      XorBits := DupBits(Temp, IconSize, False);
    finally
      DeleteObject(Temp);
    end;
    with BI do
    begin
      Inc(Longint(Bits), biSizeImage);
      biBitCount := 1;
      biSizeImage := BytesPerScanline(biWidth, biBitCount, 32) * biHeight;
      biClrUsed := 2;
      biClrImportant := 2;
    end;
    Colors := Pointer(Longint(@BI) + SizeOf(BI));
    Colors^[0] := 0;
    Colors^[1] := $FFFFFF;
    Temp := GDICheck(CreateDIBitmap(DC, BI, CBM_INIT, Bits, PBitmapInfo(@BI)^, DIB_RGB_COLORS));
    try
      AndBits := DupBits(Temp, IconSize, True);
    finally
      DeleteObject(Temp);
    end;
  finally
    ReleaseDC(0, DC);
  end;
end;

procedure ReadIcon(Stream: TStream; var Icon: HICON; ImageCount: Integer;
  StartOffset: Integer; const RequestedSize: TPoint; var IconSize: TPoint);
type
  PIconRecArray = ^TIconRecArray;
  TIconRecArray = array[0..300] of TIconRec;
var
  List: PIconRecArray;
  HeaderLen, Length: Integer;
  BitsPerPixel: Word;
  Colors, BestColor, C1, N, Index: Integer;
  DC: HDC;
  BI: PBitmapInfoHeader;
  ResData: Pointer;
  XorBits, AndBits: HBITMAP;
  XorInfo, AndInfo: Windows.TBitmap;
  XorMem, AndMem: Pointer;
  XorLen, AndLen: Integer;

  function AdjustColor(I: Integer): Integer;
  begin
    if I = 0 then
      Result := MaxInt
    else
      Result := I;
  end;

  function BetterSize(const Old, New: TIconRec): Boolean;
  var
    NewX, NewY, OldX, OldY: Integer;
  begin
    NewX := New.Width - IconSize.X;
    NewY := New.Height - IconSize.Y;
    OldX := Old.Width - IconSize.X;
    OldY := Old.Height - IconSize.Y;
    Result := (Abs(NewX) <= Abs(OldX)) and ((NewX <= 0) or (NewX <= OldX)) and
       (Abs(NewY) <= Abs(OldY)) and ((NewY <= 0) or (NewY <= OldY));
  end;

begin
  HeaderLen := SizeOf(TIconRec) * ImageCount;
  List := AllocMem(HeaderLen);
  try
    Stream.Read(List^, HeaderLen);
    if (RequestedSize.X or RequestedSize.Y) = 0 then
    begin
      IconSize.X := GetSystemMetrics(SM_CXICON);
      IconSize.Y := GetSystemMetrics(SM_CYICON);
    end
    else
      IconSize := RequestedSize;
    DC := GetDC(0);
    if DC = 0 then OutOfResources;
    try
      BitsPerPixel := GetDeviceCaps(DC, PLANES) * GetDeviceCaps(DC, BITSPIXEL);
      if BitsPerPixel > 8 then
        Colors := MaxInt
      else
        Colors := 1 shl BitsPerPixel;
    finally
      ReleaseDC(0, DC);
    end;

    { Find the image that most closely matches (<=) the current screen color
      depth and the requested image size.  }
    Index := 0;
    BestColor := AdjustColor(List^[0].Colors);
    for N := 1 to ImageCount-1 do
    begin
      C1 := AdjustColor(List^[N].Colors);
      if (C1 <= Colors) and (C1 >= BestColor) and
        BetterSize(List^[Index], List^[N]) then
      begin
        Index := N;
        BestColor := C1;
      end;
    end;

    with List^[Index] do
    begin
      IconSize.X := Width;
      IconSize.Y := Height;
      BI := AllocMem(DIBSize);
      try
        Stream.Seek(DIBOffset  - (HeaderLen + StartOffset), 1);
        Stream.Read(BI^, DIBSize);
        TwoBitsFromDIB(BI^, XorBits, AndBits, IconSize);
        GetObject(AndBits, SizeOf(Windows.TBitmap), @AndInfo);
        GetObject(XorBits, SizeOf(Windows.TBitmap), @XorInfo);
        with AndInfo do
          AndLen := bmWidthBytes * bmHeight * bmPlanes;
        with XorInfo do
          XorLen :=  bmWidthBytes * bmHeight * bmPlanes;
        Length := AndLen + XorLen;
        ResData := AllocMem(Length);
        try
          AndMem := ResData;
          with AndInfo do
            XorMem := Pointer(Longint(ResData) + AndLen);
          GetBitmapBits(AndBits, AndLen, AndMem);
          GetBitmapBits(XorBits, XorLen, XorMem);
          DeleteObject(XorBits);
          DeleteObject(AndBits);
          Icon := CreateIcon(HInstance, IconSize.X, IconSize.Y,
            XorInfo.bmPlanes, XorInfo.bmBitsPixel, AndMem, XorMem);
          if Icon = 0 then GDIError;
        finally
          FreeMem(ResData, Length);
        end;
      finally
        FreeMem(BI, DIBSize);
      end;
    end;
  finally
    FreeMem(List, HeaderLen);
  end;
end;

procedure OutOfResources;
begin
  raise Exception.Create('SOutOfResources');
end;
{$ENDIF}

function CreateArrowBitmap:TBitmap;
var
  C: TCustomBitmap;
begin
  Result:=TBitmap.Create;
  C:=RxCreateResBitmap('rxbtn_downarrow');
  Result.Assign(C);
  C.Free;
end;

function RxCreateResBitmap(const AResName: string): TCustomBitmap;
var
  ResHandle: TLResource;
begin
  ResHandle := LazarusResources.Find(AResName);
  if ResHandle <> nil then
    Result := CreateBitmapFromLazarusResource(ResHandle)
  else
    Result := CreateBitmapFromResourceName(HInstance, AResName);
end;

procedure RxAssignBitmap(const AGlyph: TBitmap; const AResName: string);
var
  C: TCustomBitmap;
begin
  C:=RxCreateResBitmap(AResName);
  AGlyph.Assign(C);
  C.Free;
end;

function GetWorkingCanvas(const Canvas: TCanvas): TCanvas;
var
  DC: HDC;
begin
  if (Canvas=nil) or (not Canvas.HandleAllocated) then
  begin
    DC := GetDC(0);
    Result := TCanvas.Create;
    Result.Handle := DC;
  end
  else
    Result := Canvas;
end;


procedure FreeWorkingCanvas(canvas: TCanvas);
begin
  ReleaseDC(0, Canvas.Handle);
  Canvas.Free;
end;

procedure RaiseIndexOutOfBounds(Control: TControl; Items:TStrings; Index: integer);
begin
  raise Exception.CreateFmt(rsIndexOutOfBounds,
                            [Control.Name, Index, Items.Count - 1]);
end;

const
  ALIGN_FLAGS_HEADER: array[TAlignment] of integer =
    (DT_LEFT or {DT_EXPANDTABS or} DT_NOPREFIX,
    DT_RIGHT or {DT_EXPANDTABS or }DT_NOPREFIX,
    DT_CENTER or {DT_EXPANDTABS or }DT_NOPREFIX);

procedure WriteTextHeader(ACanvas: TCanvas; ARect: TRect; const Text: string; Alignment: TAlignment);
var
  DrawRect: TRect;
  W, CnvW: integer;
begin
(*
dec(ARect.Right, constCellPadding);
case Canvas.TextStyle.Alignment of
  Classes.taLeftJustify: Inc(ARect.Left, constCellPadding);
  Classes.taRightJustify: Dec(ARect.Right, 1);
end;
case Canvas.TextStyle.Layout of
  tlTop: Inc(ARect.Top, constCellPadding);
  tlBottom: Dec(ARect.Bottom, constCellPadding);
end;

if ARect.Right<ARect.Left then
  ARect.Right:=ARect.Left;
if ARect.Left>ARect.Right then
  ARect.Left:=ARect.Right;
if ARect.Bottom<ARect.Top then
  ARect.Bottom:=ARect.Top;
if ARect.Top>ARect.Bottom then
  ARect.Top:=ARect.Bottom;

if (ARect.Left<>ARect.Right) and (ARect.Top<>ARect.Bottom) then
*)


  DrawRect := Rect(ARect.Left + constCellPadding, ARect.Top + constCellPadding, ARect.Right - constCellPadding, ARect.Bottom - constCellPadding);

  CnvW := Max(DrawRect.Right - DrawRect.Left, 1);
  W := (ACanvas.TextWidth(Text) div CnvW) + 1;

  DrawRect.Top := ((ARect.Top + ARect.Bottom) div 2) - W * ACanvas.TextHeight('Wg') div 2;
  if DrawRect.Top < ARect.Top + 1 then
    DrawRect.Top := ARect.Top + 1;

  SetBkMode(ACanvas.Handle, TRANSPARENT);
  DrawText(ACanvas.Handle, PChar(Text), Length(Text), DrawRect,
    //    DT_VCENTER or  DT_WORDBREAK or DT_CENTER
    ALIGN_FLAGS_HEADER[Alignment] {or DT_VCENTER or  DT_END_ELLIPSIS } or DT_WORDBREAK
    );
end;
(*
function PaletteColor(Color: TColor): Longint;
begin
  Result := ColorToRGB(Color) or PaletteMask;
end;

procedure StretchBltTransparent(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
  SrcDC: HDC; SrcX, SrcY, SrcW, Srch: Integer; Palette: HPALETTE;
  TransparentColor: TColorRef);
var
  Color: TColorRef;
  bmAndBack, bmAndObject, bmAndMem, bmSave: HBITMAP;
  bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBITMAP;
  MemDC, BackDC, ObjectDC, SaveDC: HDC;
  palDst, palMem, palSave, palObj: HPALETTE;
begin
  { Create some DCs to hold temporary data }
  BackDC := CreateCompatibleDC(DstDC);
  ObjectDC := CreateCompatibleDC(DstDC);
  MemDC := CreateCompatibleDC(DstDC);
  SaveDC := CreateCompatibleDC(DstDC);
  { Create a bitmap for each DC }
  bmAndObject := CreateBitmap(SrcW, Srch, 1, 1, nil);
  bmAndBack := CreateBitmap(SrcW, Srch, 1, 1, nil);
  bmAndMem := CreateCompatibleBitmap(DstDC, DstW, DstH);
  bmSave := CreateCompatibleBitmap(DstDC, SrcW, Srch);
  { Each DC must select a bitmap object to store pixel data }
  bmBackOld := SelectObject(BackDC, bmAndBack);
  bmObjectOld := SelectObject(ObjectDC, bmAndObject);
  bmMemOld := SelectObject(MemDC, bmAndMem);
  bmSaveOld := SelectObject(SaveDC, bmSave);
  { Select palette }
  palDst := 0;
  palMem := 0;
  palSave := 0;
  palObj := 0;
  if Palette <> 0 then
  begin
    palDst := SelectPalette(DstDC, Palette, True);
    RealizePalette(DstDC);
    palSave := SelectPalette(SaveDC, Palette, False);
    RealizePalette(SaveDC);
    palObj := SelectPalette(ObjectDC, Palette, False);
    RealizePalette(ObjectDC);
    palMem := SelectPalette(MemDC, Palette, True);
    RealizePalette(MemDC);
  end;
  { Set proper mapping mode }
  SetMapMode(SrcDC, GetMapMode(DstDC));
  SetMapMode(SaveDC, GetMapMode(DstDC));
  { Save the bitmap sent here }
  BitBlt(SaveDC, 0, 0, SrcW, Srch, SrcDC, SrcX, SrcY, SRCCOPY);
  { Set the background color of the source DC to the color,         }
  { contained in the parts of the bitmap that should be transparent }
  Color := SetBkColor(SaveDC, PaletteColor(TransparentColor));
  { Create the object mask for the bitmap by performing a BitBlt()  }
  { from the source bitmap to a monochrome bitmap                   }
  BitBlt(ObjectDC, 0, 0, SrcW, Srch, SaveDC, 0, 0, SRCCOPY);
  { Set the background color of the source DC back to the original  }
  SetBkColor(SaveDC, Color);
  { Create the inverse of the object mask }
  BitBlt(BackDC, 0, 0, SrcW, Srch, ObjectDC, 0, 0, NOTSRCCOPY);
  { Copy the background of the main DC to the destination }
  BitBlt(MemDC, 0, 0, DstW, DstH, DstDC, DstX, DstY, SRCCOPY);
  { Mask out the places where the bitmap will be placed }
  StretchBlt(MemDC, 0, 0, DstW, DstH, ObjectDC, 0, 0, SrcW, Srch, SRCAND);
  { Mask out the transparent colored pixels on the bitmap }
  BitBlt(SaveDC, 0, 0, SrcW, Srch, BackDC, 0, 0, SRCAND);
  { XOR the bitmap with the background on the destination DC }
  StretchBlt(MemDC, 0, 0, DstW, DstH, SaveDC, 0, 0, SrcW, Srch, SRCPAINT);
  { Copy the destination to the screen }
  BitBlt(DstDC, DstX, DstY, DstW, DstH, MemDC, 0, 0, SRCCOPY);
  { Restore palette }
  if Palette <> 0 then
  begin
    SelectPalette(MemDC, palMem, False);
    SelectPalette(ObjectDC, palObj, False);
    SelectPalette(SaveDC, palSave, False);
    SelectPalette(DstDC, palDst, True);
  end;
  { Delete the memory bitmaps }
  DeleteObject(SelectObject(BackDC, bmBackOld));
  DeleteObject(SelectObject(ObjectDC, bmObjectOld));
  DeleteObject(SelectObject(MemDC, bmMemOld));
  DeleteObject(SelectObject(SaveDC, bmSaveOld));
  { Delete the memory DCs }
  DeleteDC(MemDC);
  DeleteDC(BackDC);
  DeleteDC(ObjectDC);
  DeleteDC(SaveDC);
end;

procedure StretchBitmapTransparent(Dest: TCanvas; Bitmap: TBitmap;
  TransparentColor: TColor; DstX, DstY, DstW, DstH, SrcX, SrcY,
  SrcW, Srch: Integer);
var
  CanvasChanging: TNotifyEvent;
begin
  if DstW <= 0 then
    DstW := Bitmap.Width;
  if DstH <= 0 then
    DstH := Bitmap.Height;
  if (SrcW <= 0) or (Srch <= 0) then
  begin
    SrcX := 0;
    SrcY := 0;
    SrcW := Bitmap.Width;
    Srch := Bitmap.Height;
  end;
  if not Bitmap.Monochrome then
    SetStretchBltMode(Dest.Handle, STRETCH_DELETESCANS);
  CanvasChanging := Bitmap.Canvas.OnChanging;
  Bitmap.Canvas.Lock;
  try
    Bitmap.Canvas.OnChanging := nil;
    if TransparentColor = clNone then
    begin
      StretchBlt(Dest.Handle, DstX, DstY, DstW, DstH, Bitmap.Canvas.Handle,
        SrcX, SrcY, SrcW, Srch, Cardinal(Dest.CopyMode));
    end
    else
    begin
      if TransparentColor = clDefault then
        TransparentColor := Bitmap.Canvas.Pixels[0, Bitmap.Height - 1];
      if Bitmap.Monochrome then
        TransparentColor := clWhite
      else
        TransparentColor := ColorToRGB(TransparentColor);
      StretchBltTransparent(Dest.Handle, DstX, DstY, DstW, DstH,
        Bitmap.Canvas.Handle, SrcX, SrcY, SrcW, Srch,
        Bitmap.Palette, TransparentColor);
    end;
  finally
    Bitmap.Canvas.OnChanging := CanvasChanging;
    Bitmap.Canvas.Unlock;
  end;
end;

procedure DrawBitmapTransparent(Dest: TCanvas; DstX, DstY: Integer;
  Bitmap: TBitmap; TransparentColor: TColor);
begin
  StretchBitmapTransparent(Dest, Bitmap, TransparentColor, DstX, DstY,
    Bitmap.Width, Bitmap.Height, 0, 0, Bitmap.Width, Bitmap.Height);
end;    *)

initialization
{$IFDEF RX_USE_LAZARUS_RESOURCE}
  LazarusResources.Add('rxbtn_downarrow','XPM',[
  '/* XPM */'#13#10'static char * btn_downarrow_xpm[] = {'#13#10'"5 3 2 1",'#13
  +#10'" '#9'c None",'#13#10'".'#9'c #000000",'#13#10'".....",'#13#10'" ... ",'
  +#13#10'"  .  "};'#13#10]);
{$ENDIF}

end.


