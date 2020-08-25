unit SLP.Types;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

interface

uses
  Windows;


const
  TIME_MAX = High(UINT);

type

  TAppParams = record
    ShowTime: Boolean;     // -st, --show-time
    TimeToWait: Int64;
  end;

  
implementation

end.
