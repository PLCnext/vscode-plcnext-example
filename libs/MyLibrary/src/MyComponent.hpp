#pragma once
#include "Arp/System/Core/Arp.h"
#include "Arp/System/Acf/ComponentBase.hpp"
#include "Arp/System/Acf/IApplication.hpp"
#include "Arp/Plc/Commons/Esm/ProgramComponentBase.hpp"
#include "MyComponentProgramProvider.hpp"
#include "MyLibraryLibrary.hpp"
#include "Arp/Plc/Commons/Meta/MetaLibraryBase.hpp"
#include "Arp/System/Commons/Logging.h"

namespace ExampleA13b { namespace MyLibrary
{

using namespace Arp;
using namespace Arp::System::Acf;
using namespace Arp::Plc::Commons::Esm;
using namespace Arp::Plc::Commons::Meta;

//#component
class MyComponent : public ComponentBase, public ProgramComponentBase, private Loggable<MyComponent>
{
public: // typedefs

public: // construction/destruction
    MyComponent(IApplication& application, const String& name);
    virtual ~MyComponent() = default;

public: // IComponent operations
    void Initialize() override;
    void LoadConfig() override;
    void SetupConfig() override;
    void ResetConfig() override;

public: // ProgramComponentBase operations
    void RegisterComponentPorts() override;

private: // methods
    MyComponent(const MyComponent& arg) = delete;
    MyComponent& operator= (const MyComponent& arg) = delete;

public: // static factory operations
    static IComponent::Ptr Create(Arp::System::Acf::IApplication& application, const String& name);

private: // fields
    MyComponentProgramProvider programProvider;

public: /* Ports
           =====
           Component ports are defined in the following way:
           //#port
           //#name(NameOfPort)
           boolean portField;

           The name comment defines the name of the port and is optional. Default is the name of the field.
           Attributes which are defined for a component port are IGNORED. If component ports with attributes
           are necessary, define a single structure port where attributes can be defined foreach field of the
           structure.
        */
};

///////////////////////////////////////////////////////////////////////////////
// inline methods of class MyComponent
inline MyComponent::MyComponent(IApplication& application, const String& name)
: ComponentBase(application, ::ExampleA13b::MyLibrary::MyLibraryLibrary::GetInstance(), name, ComponentCategory::Custom)
, programProvider(*this)
, ProgramComponentBase(::ExampleA13b::MyLibrary::MyLibraryLibrary::GetInstance().GetNamespace(), programProvider)
{
}

inline IComponent::Ptr MyComponent::Create(Arp::System::Acf::IApplication& application, const String& name)
{
    return IComponent::Ptr(new MyComponent(application, name));
}

}} // end of namespace ExampleA13b.MyLibrary
