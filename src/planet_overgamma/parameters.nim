## User-defined parameters for things like world generators, machines, etc.

import std/tables

type
  ParameterDataType* = enum
    ## A parameter's data type.
    pdtInt = "int"
    pdtFloat = "float"
    pdtString = "string"

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

proc inputBoxParam*(dataType: ParameterDataType): Parameter =
  ## Creates and initializes an input box parameter.
  Parameter(kind: pkInputBox, dataType: dataType)

proc sliderParam*(dataType: ParameterDataType, range: Slice[float]): Parameter =
  ## Creates and initializes a slider parameter.
  Parameter(kind: pkSlider, dataType: dataType, sliderRange: range)

proc dragParam*(dataType: ParameterDataType): Parameter =
  ## Creates and initializes a drag parameter.
  Parameter(kind: pkDrag, dataType: dataType)

proc arg*(value: int32): Argument =
  ## Creates an int argument.
  Argument(dataType: pdtInt, intValue: value)

proc arg*(value: float32): Argument =
  ## Creates a float argument.
  Argument(dataType: pdtFloat, floatValue: value)

proc arg*(value: string): Argument =
  ## Creates a string argument.
  Argument(dataType: pdtString, stringValue: value)
