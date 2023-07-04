////////////////////////////////////////
// AVDECC LIBRARY SWIG file
////////////////////////////////////////

%module(directors="1") avdecc

%include <stl.i>
%include <std_string.i>
%include <std_set.i>
%include <stdint.i>
%include <std_pair.i>
%include <std_map.i>
%include <windows.i>
%include <std_unique_ptr.i>
#if 0
%include <swiginterface.i>
#endif
#ifdef SWIGCSHARP
%include <arrays_csharp.i>
#endif
%include "la/avdecc/internals/chrono.i"
%include "la/avdecc/internals/optional.i"
%include "la/avdecc/internals/std_function.i"

// Generated wrapper file needs to include our header file (include as soon as possible using 'insert(runtime)' as target language exceptions are defined early in the generated wrapper file)
%insert(runtime) %{
	#include <la/avdecc/memoryBuffer.hpp>
	#include <la/avdecc/executor.hpp>
	#include <la/avdecc/avdecc.hpp>
	#include <la/avdecc/internals/exception.hpp>
	#include <la/avdecc/internals/entity.hpp>
	#include <la/avdecc/internals/controllerEntity.hpp>
	#include <la/avdecc/internals/endStation.hpp>
%}

// Optimize code generation be enabling RVO
%typemap(out, optimal="1") SWIGTYPE
%{
	$result = new $1_ltype((const $1_ltype &)$1);
%}

#define LA_AVDECC_API
#define LA_AVDECC_CALL_CONVENTION

////////////////////////////////////////
// Utils
////////////////////////////////////////
%include "la/avdecc/utils.i"


////////////////////////////////////////
// MemoryBuffer class
////////////////////////////////////////
%nspace la::avdecc::MemoryBuffer;
%rename("isEqual") la::avdecc::MemoryBuffer::operator==;
%rename("isDifferent") la::avdecc::MemoryBuffer::operator!=;
%ignore la::avdecc::MemoryBuffer::operator bool; // Ignore operator bool, isValid() is already defined
// Currently no resolution is performed in order to match function parameters. This means function parameter types must match exactly. For example, namespace qualifiers and typedefs will not work.
%ignore la::avdecc::MemoryBuffer::operator=;
// Ignore move constructor
%ignore la::avdecc::MemoryBuffer::MemoryBuffer(MemoryBuffer&&);
// Rename const data() getter
//%rename("constData") la::avdecc::MemoryBuffer::data() const; // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER
%ignore la::avdecc::MemoryBuffer::data(); // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER
%ignore la::avdecc::MemoryBuffer::data() const; // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER

#ifdef SWIGCSHARP
// Marshalling for void pointers
%apply unsigned char INPUT[]  { void const* const }
#endif

// Include c++ declaration file
%include "la/avdecc/memoryBuffer.hpp"


////////////////////////////////////////
// Executor/ExecutorManager classes
////////////////////////////////////////
%nspace la::avdecc::ExecutorManager;
%ignore la::avdecc::ExecutorManager::pushJob(std::string const& name, Executor::Job&& job); // Disable this version of the method, we'll wrap it
%ignore la::avdecc::ExecutorManager::isExecutorRegistered; // RIGHT NOW IGNORE THIS METHOD
%ignore la::avdecc::ExecutorManager::registerExecutor; // RIGHT NOW IGNORE THIS METHOD
%ignore la::avdecc::ExecutorManager::destroyExecutor; // RIGHT NOW IGNORE THIS METHOD
%ignore la::avdecc::ExecutorManager::getExecutorThread; // RIGHT NOW IGNORE THIS METHOD
%ignore la::avdecc::ExecutorManager::ExecutorWrapper; // RIGHT NOW IGNORE THIS CLASS
%ignore la::avdecc::Executor; // RIGHT NOW IGNORE THIS CLASS
%ignore la::avdecc::ExecutorWithDispatchQueue; // RIGHT NOW IGNORE THIS CLASS
%ignore la::avdecc::ExecutorProxy; // RIGHT NOW IGNORE THIS CLASS

%feature("director") la::avdecc::executorManager::PushJobHandler;
%nspace la::avdecc::executorManager::PushJobHandler;
%inline %{
	namespace la::avdecc::executorManager
	{
	class PushJobHandler
	{
		public:
			virtual void call() = 0;
			virtual ~PushJobHandler() {}
	};
	} // namespace la::avdecc::executorManager
%}

// Include c++ declaration file
%include "la/avdecc/executor.hpp"

// Define some wrapper functions
%extend la::avdecc::ExecutorManager
{
public:
    void pushJob(std::string const& name, executorManager::PushJobHandler* handler)
    {
        self->pushJob(name, [handler]()
        {
            if (handler)
            {
                handler->call();
            }
        });
    }
};


////////////////////////////////////////
// avdecc global
////////////////////////////////////////
%ignore la::avdecc::CompileOption;
%ignore la::avdecc::CompileOptionInfo;
%ignore la::avdecc::getCompileOptions();
%ignore la::avdecc::getCompileOptionsInfo();

// Include c++ declaration file
%include "la/avdecc/avdecc.hpp"


////////////////////////////////////////
// Exception class
////////////////////////////////////////
%nspace la::avdecc::Exception;
// Currently no resolution is performed in order to match function parameters. This means function parameter types must match exactly. For example, namespace qualifiers and typedefs will not work.
%ignore la::avdecc::Exception::operator=;
// Ignore char* constructor
%ignore la::avdecc::Exception::Exception(char const* const);
// Ignore move constructor
%ignore la::avdecc::Exception::Exception(Exception&&);

// Include c++ declaration file
%include "la/avdecc/internals/exception.hpp"

////////////////////////////////////////
// Entity Model
////////////////////////////////////////
// Define optionals before including entityModel.i (we need to declare the optionals before the underlying types are defined)
DEFINE_OPTIONAL_SIMPLE(OptUInt8, std::uint8_t, (byte)0)
DEFINE_OPTIONAL_SIMPLE(OptUInt16, std::uint16_t, (ushort)0)
DEFINE_OPTIONAL_SIMPLE(OptUInt32, std::uint32_t, (uint)0)
DEFINE_OPTIONAL_SIMPLE(OptUInt64, std::uint64_t, (ulong)0)
//DEFINE_OPTIONAL_SIMPLE(OptDescriptorIndex, la::avdecc::entity::model::DescriptorIndex, avdeccEntityModel.getInvalidDescriptorIndex()) // Currently we cannot define both OptUInt16 and OptDescriptorIndex (or they mix up). We'll define each Descriptor type once we use a TypedDefine
DEFINE_OPTIONAL_SIMPLE(OptMsrpFailureCode, la::avdecc::entity::model::MsrpFailureCode, la.avdecc.entity.model.MsrpFailureCode.NoFailure)
DEFINE_OPTIONAL_CLASS(la::avdecc, UniqueIdentifier, OptUniqueIdentifier)
DEFINE_OPTIONAL_CLASS(la::networkInterface, MacAddress, OptMacAddress)

// Import entity model
%import "la/avdecc/internals/entityModel.i"


////////////////////////////////////////
// Entity/LocalEntity
////////////////////////////////////////
// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

%nspace la::avdecc::entity::Entity;
%rename("%s") la::avdecc::entity::Entity; // Unignore class
%ignore la::avdecc::entity::Entity::Entity(Entity&&); // Ignore move constructor
%ignore la::avdecc::entity::Entity::operator=; // Ignore copy operator
%ignore la::avdecc::entity::Entity::getCommonInformation() const; // Ignore const overload
%ignore la::avdecc::entity::Entity::getInterfaceInformation(model::AvbInterfaceIndex const interfaceIndex) const; // Ignore const overload
%ignore la::avdecc::entity::Entity::getInterfacesInformation() const; // Ignore const overload
%nspace la::avdecc::entity::Entity::CommonInformation;
%rename("%s") la::avdecc::entity::Entity::CommonInformation; // Unignore child struct
%nspace la::avdecc::entity::Entity::InterfaceInformation;
%rename("%s") la::avdecc::entity::Entity::InterfaceInformation; // Unignore child struct

%nspace la::avdecc::entity::LocalEntity;
%rename("%s") la::avdecc::entity::LocalEntity; // Unignore class
%rename("lockEntity") la::avdecc::entity::LocalEntity::lock; // Rename method
%rename("unlockEntity") la::avdecc::entity::LocalEntity::unlock; // Rename method
%typemap(csbase) la::avdecc::entity::LocalEntity::AemCommandStatus "ushort"
%typemap(csbase) la::avdecc::entity::LocalEntity::AaCommandStatus "ushort"
%typemap(csbase) la::avdecc::entity::LocalEntity::MvuCommandStatus "ushort"
%typemap(csbase) la::avdecc::entity::LocalEntity::ControlStatus "ushort"
%typemap(csbase) la::avdecc::entity::LocalEntity::AdvertiseFlag "uint" // Currently hardcode as uint because of SWIG issue https://github.com/swig/swig/issues/2576
%rename("not") operator!(LocalEntity::AemCommandStatus const status); // Not put in a namespace https://github.com/swig/swig/issues/2459
%rename("or") operator|(LocalEntity::AemCommandStatus const lhs, LocalEntity::AemCommandStatus const rhs); // Not put in a namespace https://github.com/swig/swig/issues/2459
%ignore operator|=(LocalEntity::AemCommandStatus& lhs, LocalEntity::AemCommandStatus const rhs); // Don't know how to properly bind this with correct type defined (SWIG generates a SWIGTYPE_p file for this)
%rename("not") operator!(LocalEntity::AaCommandStatus const status); // Not put in a namespace https://github.com/swig/swig/issues/2459
%rename("or") operator|(LocalEntity::AaCommandStatus const lhs, LocalEntity::AaCommandStatus const rhs); // Not put in a namespace https://github.com/swig/swig/issues/2459
%ignore operator|=(LocalEntity::AaCommandStatus& lhs, LocalEntity::AaCommandStatus const rhs); // Don't know how to properly bind this with correct type defined (SWIG generates a SWIGTYPE_p file for this)
%rename("not") operator!(LocalEntity::MvuCommandStatus const status); // Not put in a namespace https://github.com/swig/swig/issues/2459
%rename("or") operator|(LocalEntity::MvuCommandStatus const lhs, LocalEntity::MvuCommandStatus const rhs); // Not put in a namespace https://github.com/swig/swig/issues/2459
%ignore operator|=(LocalEntity::MvuCommandStatus& lhs, LocalEntity::MvuCommandStatus const rhs); // Don't know how to properly bind this with correct type defined (SWIG generates a SWIGTYPE_p file for this)
%rename("not") operator!(LocalEntity::ControlStatus const status); // Not put in a namespace https://github.com/swig/swig/issues/2459
%rename("or") operator|(LocalEntity::ControlStatus const lhs, LocalEntity::ControlStatus const rhs); // Not put in a namespace https://github.com/swig/swig/issues/2459
%ignore operator|=(LocalEntity::ControlStatus& lhs, LocalEntity::ControlStatus const rhs); // Don't know how to properly bind this due to const overload
%ignore operator|=(LocalEntity::ControlStatus const lhs, LocalEntity::ControlStatus const rhs); // Don't know how to properly bind this due to const overload

// Include c++ declaration file
%include "la/avdecc/internals/entity.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes

// Define templates
%template(InterfaceInformationMap) std::map<la::avdecc::entity::model::AvbInterfaceIndex, la::avdecc::entity::Entity::InterfaceInformation>;

////////////////////////////////////////
// ControllerEntity
////////////////////////////////////////
// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

%nspace la::avdecc::entity::controller::Interface;
#if 1
%ignore la::avdecc::entity::controller::Interface; // TEMP IGNORE CLASS UNTIL WE CAN WRAP ALL RESULT HANDLERS
#else
%rename("%s") la::avdecc::entity::controller::Interface; // Unignore class
#endif
%ignore la::avdecc::entity::controller::Interface::Interface(Interface&&); // Ignore move constructor
%ignore la::avdecc::entity::controller::Interface::operator=; // Ignore copy operator
// TODO: Must wrap all result handlers

DEFINE_OBSERVER_CLASS(la::avdecc::entity::controller::Delegate)
%ignore la::avdecc::entity::controller::Delegate::Delegate(Delegate&&); // Ignore move constructor
%ignore la::avdecc::entity::controller::Delegate::operator=; // Ignore copy operator

%nspace la::avdecc::entity::controller::Interface;
%rename("%s") la::avdecc::entity::controller::Interface; // Unignore class
// Unignore functions automatically generated by the following std_function calls (because we asked to ignore all methods earlier)
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_UniqueIdentifier_DescriptorType;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_EntityDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ConfigurationDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AudioUnitIndex_AudioUnitDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StreamIndex_StreamDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_JackIndex_JackDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AvbInterfaceIndex_AvbInterfaceDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockSourceIndex_ClockSourceDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MemoryObjectIndex_MemoryObjectDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_LocaleIndex_LocaleDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StringsIndex_StringsDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StreamPortIndex_StreamPortDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ExternalPortIndex_ExternalPortDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_InternalPortIndex_InternalPortDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClusterIndex_AudioClusterDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MapIndex_AudioMapDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ControlIndex_ControlDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockDomainIndex_ClockDomainDescriptor;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamFormat;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamPortIndex_MapIndex_MapIndex_AudioMappings;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamPortIndex_AudioMappings;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamInfo;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AvdeccFixedString;
#if TYPED_DESCRIPTOR_INDEXES
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AudioUnitIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StreamIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_JackIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AvbInterfaceIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockSourceIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MemoryObjectIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClusterIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ControlIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockDomainIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_AudioUnitIndex_SamplingRate;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ClusterIndex_SamplingRate;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamIndex;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_MemoryObjectIndex;
#else
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_DescriptorIndex;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_DescriptorIndex_AvdeccFixedString;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_DescriptorIndex_SamplingRate;
#endif
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_UniqueIdentifier;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ClockDomainIndex_ClockSourceIndex;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ControlIndex_MemoryBuffer;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_AvbInterfaceIndex_AvbInfo;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_AvbInterfaceIndex_AsPath;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_EntityCounterValidFlags_DescriptorCounters;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_AvbInterfaceIndex_AvbInterfaceCounterValidFlags_DescriptorCounters;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ClockDomainIndex_ClockDomainCounterValidFlags_DescriptorCounters;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamInputCounterValidFlags_DescriptorCounters;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamOutputCounterValidFlags_DescriptorCounters;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_DescriptorType_DescriptorIndex_OperationID_MemoryObjectOperationType_MemoryBuffer;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_DescriptorType_DescriptorIndex_OperationID;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MemoryObjectIndex_uint64_t;
%rename("%s") Handler_UniqueIdentifier_AemCommandStatus_Tlvs;
%rename("%s") Handler_UniqueIdentifier_MvuCommandStatus_MilanInfo;
%rename("%s") Handler_StreamIdentification_StreamIdentification_uint16_t_ConnectionFlags_ControlStatus;

// TODO: Would be nice to have the handler in the same namespace as the class (ie. be able to pass a namespace to std_function)
%std_function(Handler_UniqueIdentifier_AemCommandStatus_UniqueIdentifier_DescriptorType, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::UniqueIdentifier const owningEntity, la::avdecc::entity::model::DescriptorType const descriptorType, la::avdecc::entity::model::DescriptorIndex const descriptorIndex);
%std_function(Handler_UniqueIdentifier_AemCommandStatus, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_EntityDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::EntityDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ConfigurationDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ConfigurationDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AudioUnitIndex_AudioUnitDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::AudioUnitIndex const audioUnitIndex, la::avdecc::entity::model::AudioUnitDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StreamIndex_StreamDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::StreamIndex const streamIndex, la::avdecc::entity::model::StreamDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_JackIndex_JackDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::JackIndex const jackIndex, la::avdecc::entity::model::JackDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AvbInterfaceIndex_AvbInterfaceDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::AvbInterfaceIndex const avbInterfaceIndex, la::avdecc::entity::model::AvbInterfaceDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockSourceIndex_ClockSourceDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ClockSourceIndex const clockSourceIndex, la::avdecc::entity::model::ClockSourceDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MemoryObjectIndex_MemoryObjectDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::MemoryObjectIndex const memoryObjectIndex, la::avdecc::entity::model::MemoryObjectDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_LocaleIndex_LocaleDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::LocaleIndex const localeIndex, la::avdecc::entity::model::LocaleDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StringsIndex_StringsDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::StringsIndex const stringsIndex, la::avdecc::entity::model::StringsDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StreamPortIndex_StreamPortDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::StreamPortIndex const streamPortIndex, la::avdecc::entity::model::StreamPortDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ExternalPortIndex_ExternalPortDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ExternalPortIndex const externalPortIndex, la::avdecc::entity::model::ExternalPortDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_InternalPortIndex_InternalPortDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::InternalPortIndex const internalPortIndex, la::avdecc::entity::model::InternalPortDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClusterIndex_AudioClusterDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ClusterIndex const clusterIndex, la::avdecc::entity::model::AudioClusterDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MapIndex_AudioMapDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::MapIndex const mapIndex, la::avdecc::entity::model::AudioMapDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ControlIndex_ControlDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ControlIndex const controlIndex, la::avdecc::entity::model::ControlDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockDomainIndex_ClockDomainDescriptor, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ClockDomainIndex const clockDomainIndex, la::avdecc::entity::model::ClockDomainDescriptor const& descriptor);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamFormat, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamIndex const streamIndex, la::avdecc::entity::model::StreamFormat const streamFormat);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamPortIndex_MapIndex_MapIndex_AudioMappings, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamPortIndex const streamPortIndex, la::avdecc::entity::model::MapIndex const numberOfMaps, la::avdecc::entity::model::MapIndex const mapIndex, la::avdecc::entity::model::AudioMappings const& mappings);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamPortIndex_AudioMappings, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamPortIndex const streamPortIndex, la::avdecc::entity::model::AudioMappings const& mappings);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamInfo, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamIndex const streamIndex, la::avdecc::entity::model::StreamInfo const& info);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
#if TYPED_DESCRIPTOR_INDEXES
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AudioUnitIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::AudioUnitIndex const audioUnitIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_StreamIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::StreamIndex const streamIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_JackIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::JackIndex const jackIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_AvbInterfaceIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::AvbInterfaceIndex const avbInterfaceIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockSourceIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ClockSourceIndex const clockSourceIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MemoryObjectIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::MemoryObjectIndex const memoryObjectIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClusterIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ClusterIndex const audioClusterIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ControlIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ControlIndex const controlIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_ClockDomainIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::ClockDomainIndex const clockDomainIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_AudioUnitIndex_SamplingRate, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::AudioUnitIndex const audioUnitIndex, la::avdecc::entity::model::SamplingRate const samplingRate);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ClusterIndex_SamplingRate, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ClusterIndex const clusterIndex, la::avdecc::entity::model::SamplingRate const samplingRate);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamIndex, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamIndex const streamIndex);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_MemoryObjectIndex, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::MemoryObjectIndex const memoryObjectIndex);
#else
%std_function(Handler_UniqueIdentifier_AemCommandStatus_DescriptorIndex, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::DescriptorIndex const descriptorIndex);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_DescriptorIndex_AvdeccFixedString, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::DescriptorIndex const descriptorIndex, la::avdecc::entity::model::AvdeccFixedString const& name);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_DescriptorIndex_SamplingRate, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::DescriptorIndex const descriptorIndex, la::avdecc::entity::model::SamplingRate const samplingRate);
#endif
%std_function(Handler_UniqueIdentifier_AemCommandStatus_UniqueIdentifier, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::UniqueIdentifier const associationID);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ClockDomainIndex_ClockSourceIndex, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ClockDomainIndex const clockDomainIndex, la::avdecc::entity::model::ClockSourceIndex const clockSourceIndex);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ControlIndex_MemoryBuffer, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ControlIndex const controlIndex, la::avdecc::MemoryBuffer const& packedControlValues);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_AvbInterfaceIndex_AvbInfo, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::AvbInterfaceIndex const avbInterfaceIndex, la::avdecc::entity::model::AvbInfo const& info);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_AvbInterfaceIndex_AsPath, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::AvbInterfaceIndex const avbInterfaceIndex, la::avdecc::entity::model::AsPath const& asPath);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_EntityCounterValidFlags_DescriptorCounters, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::EntityCounterValidFlags const validCounters, la::avdecc::entity::model::DescriptorCounters const& counters);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_AvbInterfaceIndex_AvbInterfaceCounterValidFlags_DescriptorCounters, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::AvbInterfaceIndex const avbInterfaceIndex, la::avdecc::entity::AvbInterfaceCounterValidFlags const validCounters, la::avdecc::entity::model::DescriptorCounters const& counters);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ClockDomainIndex_ClockDomainCounterValidFlags_DescriptorCounters, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ClockDomainIndex const clockDomainIndex, la::avdecc::entity::ClockDomainCounterValidFlags const validCounters, la::avdecc::entity::model::DescriptorCounters const& counters);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamInputCounterValidFlags_DescriptorCounters, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamIndex const streamIndex, la::avdecc::entity::StreamInputCounterValidFlags const validCounters, la::avdecc::entity::model::DescriptorCounters const& counters);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_StreamIndex_StreamOutputCounterValidFlags_DescriptorCounters, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::StreamIndex const streamIndex, la::avdecc::entity::StreamOutputCounterValidFlags const validCounters, la::avdecc::entity::model::DescriptorCounters const& counters);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_DescriptorType_DescriptorIndex_OperationID_MemoryObjectOperationType_MemoryBuffer, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::DescriptorType const descriptorType, la::avdecc::entity::model::DescriptorIndex const descriptorIndex, la::avdecc::entity::model::OperationID const operationID, la::avdecc::entity::model::MemoryObjectOperationType const operationType, la::avdecc::MemoryBuffer const& memoryBuffer);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_DescriptorType_DescriptorIndex_OperationID, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::DescriptorType const descriptorType, la::avdecc::entity::model::DescriptorIndex const descriptorIndex, la::avdecc::entity::model::OperationID const operationID);
%std_function(Handler_UniqueIdentifier_AemCommandStatus_ConfigurationIndex_MemoryObjectIndex_uint64_t, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AemCommandStatus const status, la::avdecc::entity::model::ConfigurationIndex const configurationIndex, la::avdecc::entity::model::MemoryObjectIndex const memoryObjectIndex, std::uint64_t const length);
#if 1
%rename("$ignore") la::avdecc::entity::controller::Interface::addressAccess; // Temp ignore method
#else
%std_function(Handler_UniqueIdentifier_AemCommandStatus_Tlvs, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::AaCommandStatus const status, la::avdecc::entity::addressAccess::Tlvs const& tlvs);
#endif
%std_function(Handler_UniqueIdentifier_MvuCommandStatus_MilanInfo, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::UniqueIdentifier const entityID, la::avdecc::entity::LocalEntity::MvuCommandStatus const status, la::avdecc::entity::model::MilanInfo const& info);
%std_function(Handler_StreamIdentification_StreamIdentification_uint16_t_ConnectionFlags_ControlStatus, void, la::avdecc::entity::controller::Interface const* const controller, la::avdecc::entity::model::StreamIdentification const& talkerStream, la::avdecc::entity::model::StreamIdentification const& listenerStream, std::uint16_t const connectionCount, la::avdecc::entity::ConnectionFlags const flags, la::avdecc::entity::LocalEntity::ControlStatus const status);

%nspace la::avdecc::entity::ControllerEntity;
%rename("%s") la::avdecc::entity::ControllerEntity; // Unignore class
%ignore la::avdecc::entity::ControllerEntity::create; // Prevent direct creation of a ControllerEntity for now at it won't be usable because of double inheritance (controller::Interface methods not available)
%ignore la::avdecc::entity::ControllerEntity::ControllerEntity(ControllerEntity&&); // Ignore move constructor
%ignore la::avdecc::entity::ControllerEntity::operator=; // Ignore copy operator

// Include c++ declaration file
%include "la/avdecc/internals/controllerEntity.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes


////////////////////////////////////////
// Protocol Interface
////////////////////////////////////////
#if 0 // Too much to define right now only to get ProtocolInterface::Type
// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

%nspace la::avdecc::protocol::VuAecpdu;
%rename("%s") la::avdecc::protocol::VuAecpdu; // Unignore class

%nspace la::avdecc::protocol::ProtocolInterface;
%rename("%s") la::avdecc::protocol::ProtocolInterface; // Unignore class
//%ignore la::avdecc::protocol::ProtocolInterface::ProtocolInterface(ProtocolInterface&&); // Ignore move constructor
//%ignore la::avdecc::protocol::ProtocolInterface::operator=; // Ignore copy operator

// Include c++ declaration file
%include "la/avdecc/internals/protocolVuAecpdu.hpp"
%include "la/avdecc/internals/protocolInterface.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes
#endif


////////////////////////////////////////
// Entity Model Tree
////////////////////////////////////////
// Define some macros
%define DEFINE_AEM_TREE_COMMON(name)
	%nspace la::avdecc::entity::model::name;
	%rename("%s") la::avdecc::entity::model::name; // Unignore class
	%rename("isEqual") operator==(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
	%rename("isDifferent") operator!=(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%enddef
%define DEFINE_AEM_TREE_MODELS(name)
	%nspace la::avdecc::entity::model::name##NodeDynamicModel;
	%rename("%s") la::avdecc::entity::model::name##NodeDynamicModel; // Unignore class
	%nspace la::avdecc::entity::model::name##NodeStaticModel;
	%rename("%s") la::avdecc::entity::model::name##NodeStaticModel; // Unignore class
%enddef
%define DEFINE_AEM_TREE_NODE(name)
	%nspace la::avdecc::entity::model::name##Tree;
	%rename("%s") la::avdecc::entity::model::name##Tree; // Unignore class
%enddef
%define DEFINE_AEM_TREE_LEAF(name)
	%nspace la::avdecc::entity::model::name##NodeModels;
	%rename("%s") la::avdecc::entity::model::name##NodeModels; // Unignore class
%enddef

// Define optionals
DEFINE_OPTIONAL_SIMPLE(OptBool, bool, false)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, StreamDynamicInfo, OptStreamDynamicInfo)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, AvbInterfaceInfo, OptAvbInterfaceInfo)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, AsPath, OptAsPath)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, EntityCounters, OptEntityCounters)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, StreamInputCounters, OptStreamInputCounters)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, StreamOutputCounters, OptStreamOutputCounters)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, AvbInterfaceCounters, OptAvbInterfaceCounters)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, ClockDomainCounters, OptClockDomainCounters)

// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable
DEFINE_AEM_TREE_COMMON(StreamInputConnectionInfo)
DEFINE_AEM_TREE_COMMON(StreamDynamicInfo)
DEFINE_AEM_TREE_COMMON(AvbInterfaceInfo)
DEFINE_AEM_TREE_MODELS(AudioUnit)
DEFINE_AEM_TREE_MODELS(Stream)
DEFINE_AEM_TREE_MODELS(StreamInput)
DEFINE_AEM_TREE_MODELS(StreamOutput)
DEFINE_AEM_TREE_MODELS(Jack)
DEFINE_AEM_TREE_MODELS(AvbInterface)
DEFINE_AEM_TREE_MODELS(ClockSource)
DEFINE_AEM_TREE_MODELS(MemoryObject)
DEFINE_AEM_TREE_MODELS(Locale)
DEFINE_AEM_TREE_MODELS(Strings)
DEFINE_AEM_TREE_MODELS(StreamPort)
DEFINE_AEM_TREE_MODELS(AudioCluster)
DEFINE_AEM_TREE_MODELS(AudioMap)
DEFINE_AEM_TREE_MODELS(Control)
DEFINE_AEM_TREE_MODELS(ClockDomain)
DEFINE_AEM_TREE_MODELS(Configuration)
DEFINE_AEM_TREE_MODELS(Entity)
DEFINE_AEM_TREE_LEAF(StreamInput);
DEFINE_AEM_TREE_LEAF(StreamOutput);
DEFINE_AEM_TREE_LEAF(AvbInterface);
DEFINE_AEM_TREE_LEAF(ClockSource);
DEFINE_AEM_TREE_LEAF(MemoryObject);
DEFINE_AEM_TREE_LEAF(Strings);
DEFINE_AEM_TREE_LEAF(AudioCluster);
DEFINE_AEM_TREE_LEAF(AudioMap);
DEFINE_AEM_TREE_LEAF(Control);
DEFINE_AEM_TREE_LEAF(ClockDomain);
DEFINE_AEM_TREE_NODE(Jack);
DEFINE_AEM_TREE_NODE(Locale);
DEFINE_AEM_TREE_NODE(StreamPort);
DEFINE_AEM_TREE_NODE(AudioUnit);
DEFINE_AEM_TREE_NODE(Configuration);
DEFINE_AEM_TREE_NODE(Entity);

// Include c++ declaration file
%include "la/avdecc/internals/entityModelTreeCommon.hpp"
%include "la/avdecc/internals/entityModelTreeDynamic.hpp"
%include "la/avdecc/internals/entityModelTreeStatic.hpp"
%include "la/avdecc/internals/entityModelTree.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes

// Define templates
%template(StreamIdentificationSet) std::set<la::avdecc::entity::model::StreamIdentification>;
%template(ControlNodeModelMap) std::map<la::avdecc::entity::model::ControlIndex, la::avdecc::entity::model::ControlNodeModels>;
%template(StringsNodeModelMap) std::map<la::avdecc::entity::model::StringsIndex, la::avdecc::entity::model::StringsNodeModels>;
%template(AudioClusterNodeModelMap) std::map<la::avdecc::entity::model::ClusterIndex, la::avdecc::entity::model::AudioClusterNodeModels>;
%template(AudioMapNodeModelMap) std::map<la::avdecc::entity::model::MapIndex, la::avdecc::entity::model::AudioMapNodeModels>;
%template(StreamPortTreeMap) std::map<la::avdecc::entity::model::StreamPortIndex, la::avdecc::entity::model::StreamPortTree>;
%template(AudioUnitTreeMap) std::map<la::avdecc::entity::model::AudioUnitIndex, la::avdecc::entity::model::AudioUnitTree>;
%template(LocaleTreeMap) std::map<la::avdecc::entity::model::LocaleIndex, la::avdecc::entity::model::LocaleTree>;
%template(JackTreeMap) std::map<la::avdecc::entity::model::JackIndex, la::avdecc::entity::model::JackTree>;
%template(StreamInputNodeModelMap) std::map<la::avdecc::entity::model::StreamIndex, la::avdecc::entity::model::StreamInputNodeModels>;
%template(StreamOutputNodeModelMap) std::map<la::avdecc::entity::model::StreamIndex, la::avdecc::entity::model::StreamOutputNodeModels>;
%template(AvbInterfaceNodeModelMap) std::map<la::avdecc::entity::model::AvbInterfaceIndex, la::avdecc::entity::model::AvbInterfaceNodeModels>;
%template(ClockSourceNodeModelMap) std::map<la::avdecc::entity::model::ClockSourceIndex, la::avdecc::entity::model::ClockSourceNodeModels>;
%template(MemoryObjectNodeModelMap) std::map<la::avdecc::entity::model::MemoryObjectIndex, la::avdecc::entity::model::MemoryObjectNodeModels>;
%template(ClockDomainNodeModelMap) std::map<la::avdecc::entity::model::ClockDomainIndex, la::avdecc::entity::model::ClockDomainNodeModels>;
%template(ConfigurationTreeMap) std::map<la::avdecc::entity::model::ConfigurationIndex, la::avdecc::entity::model::ConfigurationTree>;
%template(EntityCounters) std::map<la::avdecc::entity::EntityCounterValidFlag, la::avdecc::entity::model::DescriptorCounter>;
%template(StreamInputCounters) std::map<la::avdecc::entity::StreamInputCounterValidFlag, la::avdecc::entity::model::DescriptorCounter>;
%template(StreamOutputCounters) std::map<la::avdecc::entity::StreamOutputCounterValidFlag, la::avdecc::entity::model::DescriptorCounter>;
%template(AvbInterfaceCounters) std::map<la::avdecc::entity::AvbInterfaceCounterValidFlag, la::avdecc::entity::model::DescriptorCounter>;
%template(ClockDomainCounters) std::map<la::avdecc::entity::ClockDomainCounterValidFlag, la::avdecc::entity::model::DescriptorCounter>;
%template(LocalizedStringMap) std::unordered_map<la::avdecc::entity::model::StringsIndex, la::avdecc::entity::model::AvdeccFixedString>;

////////////////////////////////////////
// JSON SERIALIZATION
////////////////////////////////////////
// Bind enums
DEFINE_ENUM_CLASS(la::avdecc::entity::model::jsonSerializer, Flag, "ushort")

// Include c++ declaration file
%include "la/avdecc/internals/jsonSerialization.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes


////////////////////////////////////////
// EndStation
////////////////////////////////////////
// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

%nspace la::avdecc::EndStation;
%rename("%s") la::avdecc::EndStation; // Unignore class
%ignore la::avdecc::EndStation::Exception; // Ignore Exception, will be created as native exception
%ignore la::avdecc::EndStation::addAggregateEntity; // Ignore at the moment, we don't want to handle AggregateEntity yet
%ignore la::avdecc::EndStation::deserializeEntityModelFromJson;
%unique_ptr(la::avdecc::EndStation) // Define unique_ptr for EndStation
// Extend the class
%extend la::avdecc::EndStation
{
public:
	static std::unique_ptr<la::avdecc::EndStation> create(/*protocol::ProtocolInterface::Type const protocolInterfaceType, */std::string const& networkInterfaceName)
	{
		try
		{
			// Right now, force PCap as we cannot bind the protocolInterfaceType enum correctly
			return std::unique_ptr<la::avdecc::EndStation>{ la::avdecc::EndStation::create(la::avdecc::protocol::ProtocolInterface::Type::PCap, networkInterfaceName).release() };
		}
		catch (la::avdecc::EndStation::Exception const& e)
		{
			SWIG_CSharpSetPendingExceptionEndStation(e.getError(), e.what());
			return nullptr;
		}
	}
};
%ignore la::avdecc::EndStation::create; // Ignore it, will be wrapped (because std::unique_ptr doesn't support custom deleters - Ticket #2411)

// Define C# exception handling for la::avdecc::EndStation::Exception
%insert(runtime) %{
	typedef void (SWIGSTDCALL* EndStationExceptionCallback_t)(la::avdecc::EndStation::Error const error, char const* const message);
	EndStationExceptionCallback_t endStationExceptionCallback = NULL;

	extern "C" SWIGEXPORT void SWIGSTDCALL EndStationExceptionRegisterCallback(EndStationExceptionCallback_t exceptionCallback)
	{
		endStationExceptionCallback = exceptionCallback;
	}

	static void SWIG_CSharpSetPendingExceptionEndStation(la::avdecc::EndStation::Error const error, char const* const message)
	{
		endStationExceptionCallback(error, message);
	}
%}
%pragma(csharp) imclasscode=%{
	class EndStationExceptionHelper
	{
		public delegate void EndStationExceptionDelegate(la.avdecc.EndStationException.Error error, string message);
		static EndStationExceptionDelegate endStationDelegate = new EndStationExceptionDelegate(SetPendingEndStationException);

		[global::System.Runtime.InteropServices.DllImport(DllImportPath, EntryPoint="EndStationExceptionRegisterCallback")]
		public static extern void EndStationExceptionRegisterCallback(EndStationExceptionDelegate endStationDelegate);

		static void SetPendingEndStationException(la.avdecc.EndStationException.Error error, string message)
		{
			SWIGPendingException.Set(new la.avdecc.EndStationException(error, message));
		}

		static EndStationExceptionHelper()
		{
			EndStationExceptionRegisterCallback(endStationDelegate);
		}
	}
	static EndStationExceptionHelper exceptionHelper = new EndStationExceptionHelper();
%}
%pragma(csharp) moduleimports=%{
namespace la.avdecc
{
	class EndStationException : global::System.ApplicationException
	{
		public enum Error
		{
			NoError = 0,
			InvalidProtocolInterfaceType = 1, /**< Selected protocol interface type is invalid. */
			InterfaceOpenError = 2, /**< Failed to open interface. */
			InterfaceNotFound = 3, /**< Specified interface not found. */
			InterfaceInvalid = 4, /**< Specified interface is invalid. */
			DuplicateEntityID = 5, /**< EntityID not available (either duplicate, or no EntityID left on the local computer). */
			InvalidEntityModel = 6, /**< Provided EntityModel is invalid. */
			InternalError = 99, /**< Internal error, please report the issue. */
		}
		public EndStationException(Error error, string message)
			: base(message)
		{
			_error = error;
		}
		Error getError()
		{
			return _error;
		}
		private Error _error = Error.NoError;
	}
}
%}
// Throw typemap
%typemap (throws, canthrow=1) la::avdecc::EndStation::Exception %{
	SWIG_CSharpSetPendingExceptionEndStation($1.getError(), $1.what());
	return $null;
%}

// Define catches for methods that can throw
%catches(la::avdecc::EndStation::Exception) la::avdecc::EndStation::create;

// Include c++ declaration file
%include "la/avdecc/internals/endStation.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes
