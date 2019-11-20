program rxfpc_gen_help;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,
  dom, XMLRead;

type

  { TLazPkgData }

  TLazPkgData = class
  private
    procedure DoLoadData;
  public
    constructor Create(AFileName:string);

  end;

  { TRxHelpApplication }

  TRxHelpApplication = class(TCustomApplication)
  private
    procedure MakeHelp(APkgName:string);
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TLazPkgData }

procedure TLazPkgData.DoLoadData;
begin

end;

constructor TLazPkgData.Create(AFileName: string);
begin

end;

{ TRxHelpApplication }

procedure TRxHelpApplication.MakeHelp(APkgName: string);
var
  P: TLazPkgData;
begin
  if FileExists(APkgName) then
  begin
    P:=TLazPkgData.Create(APkgName);
    try

    finally
      P.Free;
    end;
  end;
end;

procedure TRxHelpApplication.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  MakeHelp('dcl_rx_ctrl');
  MakeHelp('rxdbgrid_export_spreadsheet');
  MakeHelp('rx');
  MakeHelp('rx_sort_fbdataset');
  MakeHelp('rx_sort_sqldb');
  MakeHelp('rxtools.lpk');
  MakeHelp('dcl_rxtools');
  MakeHelp('rxdbgrid_print');
  MakeHelp('rxnew');
  MakeHelp('rx_sort_ibx');
  MakeHelp('rx_sort_zeos');

  // stop program loop
  Terminate;
end;

constructor TRxHelpApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TRxHelpApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TRxHelpApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TRxHelpApplication;
begin
  Application:=TRxHelpApplication.Create(nil);
  Application.Title:='RxFPCHelp';
  Application.Run;
  Application.Free;
end.

