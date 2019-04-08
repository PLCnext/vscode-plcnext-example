#pragma once
#include "Arp/System/Core/Arp.h"
#include "Arp/Plc/Commons/Esm/ProgramBase.hpp"
#include "Arp/System/Commons/Logging.h"
#include "MyComponent.hpp"
#include "NE10.h"
#include "json/json.h"

namespace ExampleA13b { namespace MyLibrary
{

using namespace Arp;
using namespace Arp::System::Commons::Diagnostics::Logging;
using namespace Arp::Plc::Commons::Esm;

//#program
//#component(ExampleA13b::MyLibrary::MyComponent)
class MyProgram : public ProgramBase, private Loggable<MyProgram>
{
public: // typedefs

public: // construction/destruction
    MyProgram(ExampleA13b::MyLibrary::MyComponent& myComponentArg, const String& name);
    MyProgram(const MyProgram& arg) = delete;
    virtual ~MyProgram() = default;

public: // operators
    MyProgram&  operator=(const MyProgram& arg) = delete;

public: // properties

public: // operations
    void    Execute() override;

public: /* Ports
           =====
           Ports are defined in the following way:
           //#port
           //#attributes(Input|Retain)
           //#name(NameOfPort)
           boolean portField;

           The attributes comment define the port attributes and is optional.
           The name comment defines the name of the port and is optional. Default is the name of the field.
        */

private: // fields
    ExampleA13b::MyLibrary::MyComponent& myComponent;

};

///////////////////////////////////////////////////////////////////////////////
// inline methods of class ProgramBase
inline MyProgram::MyProgram(ExampleA13b::MyLibrary::MyComponent& myComponentArg, const String& name)
: ProgramBase(name)
, myComponent(myComponentArg)
{
}

}} // end of namespace ExampleA13b.MyLibrary
