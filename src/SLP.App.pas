unit SLP.App;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}


interface

uses
  Windows, SysUtils,
  //JPL.Strings,
  //JPL.Conversion,
  {$IFDEF DEBUG}JPL.TimeLogger,{$ENDIF}
  JPL.Console, JPL.ConsoleApp, JPL.CmdLineParser, JPL.Strings, JPL.TStr, JPL.Conversion, JPL.Win.SimpleTimer, JPL.DateTime,
  //JPL.Win.SimpleTimer,
  SLP.Types;

type


  TApp = class(TJPConsoleApp)
  private
    AppParams: TAppParams;
  public
    procedure Init;
    procedure Run;

    procedure RegisterOptions;
    procedure ProcessOptions;

    procedure PerformMainAction;

    procedure DisplayHelpAndExit(const ExCode: integer);
    procedure DisplayShortUsageAndExit(const Msg: string; const ExCode: integer);
    procedure DisplayBannerAndExit(const ExCode: integer);
    procedure DisplayMessageAndExit(const Msg: string; const ExCode: integer);
  end;



implementation


function NtQueryTimerResolution(var MinResolution: ULONG; var MaxResolution: ULONG; var ActualResolution: ULONG): ULONG; stdcall; external 'ntdll.dll';



{$region '                    Init                              '}

procedure TApp.Init;
const
  SEP_LINE = '-------------------------------------------------';
var
  xmin, xmax, xcurrent: ULONG;
  sTimerResMin, sTimerResMax: string;
begin
  //----------------------------------------------------------------------------

  AppName := 'Sleep';
  MajorVersion := 1;
  MinorVersion := 0;
  Self.Date := EncodeDate(2020, 8, 25);
  FullNameFormat := '%AppName% %MajorVersion%.%MinorVersion% [%OSShort% %Bits%-bit] (%AppDate%)';
  Description := 'Pauses for a specified <color=white,black>NUMBER</color> of time <color=yellow>unit</color> (seconds by default).';
  LicenseName := 'Freeware, Open Source';
  License := 'This program is completely free. You can use it without any restrictions, also for commercial purposes.' + ENDL +
    'The program''s source files are available at https://github.com/jackdp/sleep';
  Author := 'Jacek Pazera';
  HomePage := 'https://www.pazera-software.com/products/sleep/';
  HelpPage := HomePage;
  TrimExtFromExeShortName := True;

  AppParams.ShowTime := False;
  AppParams.TimeToWait := 0;

  xmin := 0;
  sTimerResMin := '';
  sTimerResMax := '';
  if NtQueryTimerResolution(xmin, xmax{%H-}, xcurrent{%H-}) = 0 then
  begin
    sTimerResMin := FormatFloat('0.000 ms', xmin / 1000 / 10);
    sTimerResMax := FormatFloat('0.000 ms', xmax / 1000 / 10);
  end;

  HintBackgroundColor := TConsole.clLightGrayBg;
  HintTextColor := TConsole.clBlackText;

  //-----------------------------------------------------------------------------

  TryHelpStr := ENDL + 'Try <color=white,black>' + ExeShortName + ' --help</color> for more information.';

  ShortUsageStr :=
    ENDL +
    'Usage: ' + ExeShortName +
    ' <color=white,black>NUMBER</color>[<color=yellow>UNIT</color>] [-st] [-h] [-V] [--license] [--home]' + ENDL +
    ENDL +
    //'Mandatory arguments to long options are mandatory for short options too.' + ENDL +
    'Options are case-sensitive. Options and values in square brackets are optional.';

  ExtraInfoStr :=
    ENDL +
    '<color=white,black>NUMBER</color>' + ENDL +
    'Any combination of real, integer, hexadecimal, or binary numbers. Each number may be followed by a time <color=yellow>unit</color> suffix. ' +
    'The total waiting time will be the sum of all the numbers provided. ' + ENDL +
    'The decimal separator in real numbers can be <color=white,darkcyan> . </color> (period) or <color=white,darkcyan> , </color> (comma).' + ENDL +
    'Hexadecimal numbers must be prefixed with <color=white,darkcyan> 0x </color> or <color=white,darkcyan> $ </color> (dollar), '+
    'eg. <color=white,black>0x0A</color>, <color=white,black>$0A</color>.' + ENDL +
    'The letter <color=black,lightgray> D </color> at the end of the number is treated as a unit of time (days), ' +
    'so if you want to set the wait time to $0D seconds, you must use <color=white,black>$ODs</color> and not <color=red>$OD</color>.' + ENDL +
    'Binary numbers must be prefixed with <color=white,darkcyan> % </color> (percent), ' +
    'eg. <color=white,black>%1010</color>.' + ENDL +

    ENDL +
    'Maximum waiting time: 2^32 ms = <color=white>' + MsToTimeStrEx(TIME_MAX) + '</color>';


  if (sTimerResMin <> '') and (sTimerResMax <> '') then ExtraInfoStr := ExtraInfoStr +
    ENDL + 'Timer resolution: min = ' + sTimerResMin + ', max = ' + sTimerResMax;

  ExtraInfoStr := ExtraInfoStr +
    ENDL + SEP_LINE + ENDL +
    'Available time units:' + ENDL +
    '  <color=yellow,black>ms</color> for milliseconds' + ENDL +
    '   <color=yellow,black>s</color> for seconds (default)' + ENDL +
    '   <color=yellow,black>m</color> for minutes' + ENDL +
    '   <color=yellow,black>h</color> for hours' + ENDL +
    '   <color=yellow,black>d</color> for days' +

    ENDL + SEP_LINE + ENDL +
    'Exit codes:' + ENDL +
    '  ' + CON_EXIT_CODE_OK.ToString + ' - OK - no errors.' + ENDL +
    '  ' + CON_EXIT_CODE_SYNTAX_ERROR.ToString + ' - Syntax error.' + ENDL +
    '  ' + CON_EXIT_CODE_ERROR.ToString + ' - Other error.';

  ExamplesStr :=
    SEP_LINE + ENDL +
    'Examples:' + ENDL +
    '  Pause for 1 second:' + ENDL + '    ' + ExeShortName + ' 1' + ENDL +
    ENDL +
    '  Pause for 3.5 minutes: ' + ENDL +
    '    ' + ExeShortName + ' 3.5m' + ENDL +
    '    ' + ExeShortName + ' "3.5 m"' + ENDL +
    '    ' + ExeShortName + ' 3m 30s' + ENDL +
    '    ' + ExeShortName + ' 3500ms' + ENDL +
    ENDL +
    '  Pause for 12h 12m 42s:' + ENDL +
    '    ' + ExeShortName + ' $ABBA' + ENDL +
    '    ' + ExeShortName + ' %1010101110111010' + ENDL +
    '    ' + ExeShortName + ' 12h 12m 42s' + ENDL +
    ENDL +
    '  Pause for 2 minutes and 50 seconds:' + ENDL +
    '    ' + ExeShortName + ' 2m 50s' + ENDL +
    '    ' + ExeShortName + ' 3m "-10s"' + ENDL +
    '    ' + ExeShortName + ' 1.7e+2';

  //------------------------------------------------------------------------------


end;
{$endregion Init}


{$region '                    Run                               '}
procedure TApp.Run;
begin
  inherited;

  RegisterOptions;
  Cmd.Parse;
  ProcessOptions;
  if Terminated then Exit;

  PerformMainAction; // <----- the main procedure
end;
{$endregion Run}


{$region '                    RegisterOptions                   '}
procedure TApp.RegisterOptions;
const
  MAX_LINE_LEN = 120;
var
  Category: string;
begin

  Cmd.CommandLineParsingMode := cpmCustom;
  Cmd.UsageFormat := cufWget;
  Cmd.AcceptAllNonOptions := True;


  // ------------ Registering command-line options -----------------

  Category := 'info';
  Cmd.RegisterOption('st', 'show-time', cvtNone, False, False, 'Show the calculated waiting time.', '', Category);
  Cmd.RegisterOption('h', 'help', cvtNone, False, False, 'Show this help.', '', Category);
  Cmd.RegisterShortOption('?', cvtNone, False, True, '', '', '');
  Cmd.RegisterOption('V', 'version', cvtNone, False, False, 'Show application version.', '', Category);
  Cmd.RegisterLongOption('license', cvtNone, False, False, 'Display program license.', '', Category);
  Cmd.RegisterLongOption('home', cvtNone, False, False, 'Opens program home page in the default browser.', '', Category);

  UsageStr :=
    ENDL +
    'Options:' + ENDL + Cmd.OptionsUsageStr('  ', 'info', MAX_LINE_LEN, '  ', 30);

end;
{$endregion RegisterOptions}


{$region '                    ProcessOptions                    '}
procedure TApp.ProcessOptions;
var
  i: integer;
  sNum: string;
  ms: Int64;
begin

  // ---------------------------- Invalid options -----------------------------------

  if Cmd.ErrorCount > 0 then
  begin
    DisplayShortUsageAndExit(Cmd.ErrorsStr, TConsole.ExitCodeSyntaxError);
    Exit;
  end;


  //------------------------------------ Help ---------------------------------------

  if (ParamCount = 0) or (Cmd.IsLongOptionExists('help')) or (Cmd.IsOptionExists('?')) then
  begin
    DisplayHelpAndExit(TConsole.ExitCodeOK);
    Exit;
  end;


  //---------------------------------- Home -----------------------------------------

  {$IFDEF MSWINDOWS}
  if Cmd.IsLongOptionExists('home') then
  begin
    GoToHomePage;
    Terminate;
    Exit;
  end;
  {$ENDIF}


  //------------------------------- Version ------------------------------------------

  if Cmd.IsOptionExists('version') then
  begin
    DisplayBannerAndExit(TConsole.ExitCodeOK);
    Exit;
  end;


  //------------------------------- Version ------------------------------------------

  if Cmd.IsLongOptionExists('license') then
  begin
    TConsole.WriteTaggedTextLine('<color=white,black>' + LicenseName + '</color>');
    DisplayLicense;
    Terminate;
    Exit;
  end;


  // --------------------------- Option: -st, --show-time -------------------------

  AppParams.ShowTime := Cmd.IsOptionExists('st');



  //---------------------------- NUMBERS --------------------------
  if Cmd.UnknownParamCount = 0 then
  begin
    DisplayError('No time interval was specified!');
    ExitCode := TConsole.ExitCodeError;
    Terminate;
    Exit;
  end;

  for i := 0 to Cmd.UnknownParamCount - 1 do
  begin
    sNum := Cmd.UnknownParams[i].ParamStr;

    if not TryGetMilliseconds(sNum, ms, tuSecond) then // Dodałem tuSecond. Zmiany w JPL.Conversion 2022.08.06
    begin
      DisplayError('Invalid time interval value: ' + sNum);
      ExitCode := TConsole.ExitCodeError;
      Terminate;
      Exit;
    end;

    AppParams.TimeToWait += ms;
  end;

  if AppParams.TimeToWait > TIME_MAX then
  begin
    DisplayError('Time interval too large: ' + MsToTimeStrEx(AppParams.TimeToWait) + ' (max = ' + MsToTimeStrEx(TIME_MAX) + ')');
    ExitCode := TConsole.ExitCodeError;
    Terminate;
  end;

end;

{$endregion ProcessOptions}



{$region '                    PerformMainAction                     '}
procedure TApp.PerformMainAction;
var
  st: TJPSimpleTimer;
  dtNow, dtEnd: TDateTime;
  msNow, msEnd: Comp;
  s, sFormat: string;

  function InsertColors(const sTime: string): string;
  var
    i, x: integer;
  begin
    Result := sTime;
    for i := 1 to Length(Result) do
      if (Result[i] <> '.') and (Result[i] <> '0') and (Result[i] <> ':') and (Result[i] <> ' ') then
      begin
        x := i;
        if (x > 1) and (Result[i - 1] = '0') then Dec(x);
        Result :=
          '<color=darkgray>' + Copy(Result, 1, x - 1) + '</color>' +
          '<color=yellow>' + Copy(Result, x, Length(Result)) + '</color>';
        Break;
      end;
  end;

begin
  if Terminated then Exit;

  if AppParams.TimeToWait < 0 then
  begin
    DisplayError('The time interval can not be a negative number.');
    ExitCode := TConsole.ExitCodeError;
    DisplayTryHelp;
    Exit;
  end;

  if AppParams.TimeToWait = 0 then Exit;

  if AppParams.ShowTime then
  begin
    dtNow := Now;
    msNow := TimeStampToMSecs(DateTimeToTimeStamp(dtNow));
    msEnd := msNow + AppParams.TimeToWait;
    dtEnd := TimeStampToDateTime(MSecsToTimeStamp(msEnd));
    sFormat := 'yyyy-mm-dd hh:nn:ss.zzz';
    s := MsToTimeStrEx(AppParams.TimeToWait, False, 'd ');
    //s := '<color=darkgray>' + s + '</color>';
    s := InsertColors(s);
    TConsole.WriteTaggedTextLine('Time to wait: ' + s + '  /  ' + TStr.InsertNumSep(AppParams.TimeToWait) + ' ms');
    TConsole.WriteTaggedTextLine('From: ' + FormatDateTime(sFormat, dtNow) + '  To: <color=cyan,black>' + FormatDateTime(sFormat, dtEnd) + '</color>');
  end;


  st := TJPSimpleTimer.Create(nil, UINT(AppParams.TimeToWait), 1);
  try

    {$IFDEF DEBUG}TTimeLogger.StartLog;{$ENDIF}
    st.Start;

  finally
    st.Free;

    {$IFDEF DEBUG}
    TTimeLogger.EndLog;
    Writeln('The real elapsed time: ', TTimeLogger.ElapsedTimeStr);
    Writeln('Difference: ', TTimeLogger.ElapsedTime - AppParams.TimeToWait, ' ms');
    {$ENDIF}
  end;


end;
{$endregion PerformMainAction}


{$region '                    Display... procs                  '}
procedure TApp.DisplayHelpAndExit(const ExCode: integer);
begin
  DisplayBanner;
  DisplayShortUsage;
  DisplayUsage;
  DisplayExtraInfo;
  DisplayExamples;

  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayShortUsageAndExit(const Msg: string; const ExCode: integer);
begin
  if Msg <> '' then Writeln(Msg);
  DisplayShortUsage;
  DisplayTryHelp;
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayBannerAndExit(const ExCode: integer);
begin
  DisplayBanner;
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayMessageAndExit(const Msg: string; const ExCode: integer);
begin
  Writeln(Msg);
  ExitCode := ExCode;
  Terminate;
end;
{$endregion Display... procs}



end.
