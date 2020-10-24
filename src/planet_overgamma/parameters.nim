## User-defined parameters for things like world generators, machines, etc.

import std/tables

type
  ParameterDataType* = enum
    ## A parameter's data type.
    pdtInt
    pdtFloat
    pdtString

  ParameterKind* = enum
    ## A parameter's input field kind.
    pkInputBox
    pkSlider
    pkDrag

  Parameter* = object
    ## A parameter.
    dataType*: ParameterDataType
    case kind*: ParameterKind
    of pkInputBox: discard
    of pkSlider:
      sliderRange*: Slice[float]
    of pkDrag: discard

  Argument* = object
    ## An argument, ie. a parameter value.
    case dataType*: ParameterDataType
    of pdtInt:
      intValue*: int32
    of pdtFloat:
      floatValue*: float32
    of pdtString:
      stringValue*: string

  Parameters* = Table[string, Parameter]
    ## A set of parameters.

  Arguments* = Table[string, Argument]
    ## A set of arguments passed to parameters.

proc param*(kind: ParameterKind, dataType: ParameterDataType): Parameter =
  ## Creates and initializes a parameter.
  Parameter(kind: kind, dataType: dataType)

proc arg*(value: int32): Argument =
  ## Creates an int argument.
  Argument(dataType: pdtInt, intValue: value)

proc arg*(value: float32): Argument =
  ## Creates a float argument.
  Argument(dataType: pdtFloat, floatValue: value)

proc arg*(value: string): Argument =
  ## Creates a string argument.
  Argument(dataType: pdtString, stringValue: value)
