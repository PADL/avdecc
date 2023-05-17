////////////////////////////////////////
// AVDECC ENTITY MODEL SWIG file
////////////////////////////////////////

%module avdeccEntityModel

%include <stdint.i>
%include <std_string.i>
%include <std_pair.i>
%include <std_vector.i>
%include <std_array.i>
%include <std_set.i>
%include "std_unordered_map.i" // From https://github.com/microsoft/CNTK/blob/master/bindings/csharp/Swig/std_unordered_map.i and https://github.com/swig/swig/pull/2480
%include "optional.i"

// Generated wrapper file needs to include our header file
%{
		#include <la/avdecc/internals/entityModel.hpp>
%}

// Optimize code generation by enabling RVO
#if defined(SWIGCSHARP)
%typemap(out, optimal="1") SWIGTYPE
%{
	$result = new $1_ltype(($1_ltype const&)$1);
%}
#endif

// Force define AVDECC C/C++ API Macros to nothing
#define LA_AVDECC_API
#define LA_AVDECC_CALL_CONVENTION

// Other defines
#define ENABLE_AVDECC_FEATURE_REDUNDANCY 1

////////////////////////////////////////
// Utils
////////////////////////////////////////
// Redefine a simplier version of some classes from la::avdecc::utils namespace (easier to parse for SWIG)
namespace la::avdecc::utils
{
template<class Derived, typename DataType>
class TypedDefine
{
public:
	using derived_type = Derived;
	using value_type = DataType;

	explicit TypedDefine(value_type const value) noexcept
		: _value(value)
	{
	}

	value_type getValue() const noexcept
	{
		return _value;
	}

	void setValue(value_type const value) noexcept
	{
		_value = value;
	}

	%rename("isEqual") operator==(TypedDefine const& v) const noexcept;
	bool operator==(TypedDefine const& v) const noexcept
	{
		return v.getValue() == _value;
	}

	%rename("isDifferent") operator!=(TypedDefine const& v) const noexcept;
	bool operator!=(TypedDefine const& v) const noexcept
	{
		return !operator==(v);
	}

	// Defaulted compiler auto-generated methods
	%ignore TypedDefine(TypedDefine&&) noexcept; // Ignore move constructor
	TypedDefine(TypedDefine&&) = default;
	TypedDefine(TypedDefine const&) = default;
	%ignore operator=; // Ignore copy operator
	TypedDefine& operator=(TypedDefine const&) = default;
	TypedDefine& operator=(TypedDefine&&) = default;

private:
	value_type _value{};
};

} // namespace la::avdecc::utils


////////////////////////////////////////
// UniqueIdentifier
////////////////////////////////////////
%nspace la::avdecc::UniqueIdentifier;
%ignore la::avdecc::UniqueIdentifier::operator value_type() const noexcept; // Ignore, don't need it
%ignore la::avdecc::UniqueIdentifier::operator bool() const noexcept; // Ignore, don't need it
%rename("isEqual") operator==(UniqueIdentifier const& lhs, UniqueIdentifier const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%rename("isDifferent") operator!=(UniqueIdentifier const& lhs, UniqueIdentifier const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%rename("isLess") operator<(UniqueIdentifier const& lhs, UniqueIdentifier const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%ignore la::avdecc::UniqueIdentifier::hash::operator(); // Ignore hash functor
%ignore la::avdecc::UniqueIdentifier::UniqueIdentifier(UniqueIdentifier&&); // Ignore move constructor
%ignore la::avdecc::UniqueIdentifier::operator=; // Ignore copy operator

%include "la/avdecc/internals/uniqueIdentifier.hpp"


////////////////////////////////////////
// Entity Model Types
////////////////////////////////////////
// Define some macros
%define DEFINE_AEM_TYPES_ENUM_CLASS(name, type)
	%nspace la::avdecc::entity::model::name;
	%typemap(csbase) la::avdecc::entity::model::name type
	%rename("isEqual") la::avdecc::entity::model::operator==(name const, name const); // Not put in a namespace https://github.com/swig/swig/issues/2459
	%rename("$ignore") la::avdecc::entity::model::operator==(name const, std::underlying_type_t<name> const);
%enddef
%define DEFINE_AEM_TYPES_STRUCT(name)
	%nspace la::avdecc::entity::model::name;
	%rename("%s") la::avdecc::entity::model::name; // Unignore class
	%rename("isEqual") operator==(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
	%rename("isDifferent") operator!=(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%enddef
%define DEFINE_AEM_TYPES_CLASS_BASE(name)
	%nspace la::avdecc::entity::model::name;
	%rename("%s") la::avdecc::entity::model::name; // Unignore class
	%ignore la::avdecc::entity::model::name::name(name&&); // Ignore move constructor
	%ignore la::avdecc::entity::model::name::operator=; // Ignore copy operator
%enddef
%define DEFINE_AEM_TYPES_CLASS(name)
	DEFINE_AEM_TYPES_CLASS_BASE(name)
	%ignore la::avdecc::entity::model::name::operator value_type() const noexcept;
	%ignore la::avdecc::entity::model::name::operator bool() const noexcept;
	%rename("isEqual") operator==(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
	%rename("isDifferent") operator!=(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
	%rename("isLess") operator<(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%enddef

// Bind enums
DEFINE_AEM_TYPES_ENUM_CLASS(AudioClusterFormat, "byte")
DEFINE_AEM_TYPES_ENUM_CLASS(ClockSourceType, "ushort")
DEFINE_AEM_TYPES_ENUM_CLASS(DescriptorType, "ushort")
%rename("isValid") la::avdecc::entity::model::operator!(DescriptorType const); // Not put in a namespace https://github.com/swig/swig/issues/2459
DEFINE_AEM_TYPES_ENUM_CLASS(JackType, "ushort")
DEFINE_AEM_TYPES_ENUM_CLASS(MemoryObjectOperationType, "ushort")
DEFINE_AEM_TYPES_ENUM_CLASS(MemoryObjectType, "ushort")
DEFINE_AEM_TYPES_ENUM_CLASS(StandardControlType, "ulong")
DEFINE_AEM_TYPES_ENUM_CLASS(ProbingStatus, "byte")
DEFINE_AEM_TYPES_ENUM_CLASS(MsrpFailureCode, "byte")

// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

DEFINE_AEM_TYPES_STRUCT(AudioMapping);
DEFINE_AEM_TYPES_STRUCT(MsrpMapping);
DEFINE_AEM_TYPES_STRUCT(StreamIdentification);
%rename("isLess") la::avdecc::entity::model::operator<(StreamIdentification const&, StreamIdentification const&); // Not put in a namespace https://github.com/swig/swig/issues/2459

DEFINE_AEM_TYPES_CLASS_BASE(AvdeccFixedString);
%ignore la::avdecc::entity::model::AvdeccFixedString::data(); // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER
%ignore la::avdecc::entity::model::AvdeccFixedString::data() const; // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER
%ignore la::avdecc::entity::model::AvdeccFixedString::AvdeccFixedString(void const* const ptr, size_t const size) noexcept; // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER
%ignore la::avdecc::entity::model::AvdeccFixedString::assign(void const* const ptr, size_t const size) noexcept; // RIGHT NOW IGNORE IT AS WE NEED TO FIND A WAY TO MARSHALL THE RETURNED POINTER
%rename("isEqual") la::avdecc::entity::model::AvdeccFixedString::operator==;
%rename("isDifferent") la::avdecc::entity::model::AvdeccFixedString::operator!=;
%rename("toString") la::avdecc::entity::model::AvdeccFixedString::operator std::string;
%ignore la::avdecc::entity::model::AvdeccFixedString::operator[](size_t const pos);
%ignore la::avdecc::entity::model::AvdeccFixedString::operator[](size_t const pos) const;
%ignore operator<<(std::ostream&, la::avdecc::entity::model::AvdeccFixedString const&);
DEFINE_AEM_TYPES_CLASS(SamplingRate);
DEFINE_AEM_TYPES_CLASS(StreamFormat);
DEFINE_AEM_TYPES_CLASS(LocalizedStringReference);
DEFINE_AEM_TYPES_CLASS(ControlValueUnit);
%typemap(csbase) la::avdecc::entity::model::ControlValueUnit::Unit "byte"
DEFINE_AEM_TYPES_CLASS(ControlValueType);
%typemap(csbase) la::avdecc::entity::model::ControlValueType::Type "ushort"
DEFINE_AEM_TYPES_CLASS_BASE(ControlValues);
%ignore la::avdecc::entity::model::ControlValues::operator bool() const noexcept;

%include "la/avdecc/internals/entityModelTypes.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes

// Define templates
%template(MultiplierUnit) std::pair<std::int8_t, la::avdecc::entity::model::ControlValueUnit::Unit>;
%template(PullBaseFrequency) std::pair<std::uint8_t, std::uint32_t>;
%template(OffsetIndex) std::pair<std::uint16_t, std::uint8_t>;
%template(AudioMappings) std::vector<la::avdecc::entity::model::AudioMapping>;
%template(MsrpMappings) std::vector<la::avdecc::entity::model::MsrpMapping>;
%template(PathSequence) std::vector<la::avdecc::UniqueIdentifier>;
%template(DescriptorCounters) std::array<la::avdecc::entity::model::DescriptorCounter, 32>;


////////////////////////////////////////
// Entity Enums
////////////////////////////////////////
// Define some macros
%define DEFINE_ENTITY_ENUM_BITFIELD_CLASS(bitfieldname, bitname, type)
	%nspace la::avdecc::entity::bitname;
#if defined(SWIGCSHARP)
	%typemap(csbase) la::avdecc::entity::bitname "uint" // Currently hardcode as uint because of SWIG issue https://github.com/swig/swig/issues/2576
#else
	%typemap(csbase) la::avdecc::entity::bitname type
#endif
	//%template(bitfieldname) la::avdecc::utils::EnumBitfield<la::avdecc::entity::bitname>;
	//%template(UnderlyingValueType) std::underlying_type_t<value_type>;
%enddef

// Bind enums
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(EntityCapabilities, EntityCapability, "uint")
//%apply std::uint32_t { la::avdecc::utils::EnumBitfield<la::avdecc::entity::EntityCapability>::underlying_value_type };
//%template(UnderlyingValueUInt) la::avdecc::utils::EnumBitfield::underlying_value_type<std::uint32_t>;
//%template(EntityCapabilities) la::avdecc::utils::EnumBitfield<la::avdecc::entity::EntityCapability>;
#if 0
template<class EnumType, typename EnumSize>
class EnumBitfield2 final
{
%typemap(csinterfaces) EnumBitfield2<EnumType, EnumSize> "global::System.IDisposable\n"

	public:
		// Constructor from a la::avdecc::utils::EnumBitfield
		EnumBitfield2(la::avdecc::utils::EnumBitfield<EnumType> const& bitfield) noexcept
			: _value{ bitfield.value() }
		{
		}
	private:
		EnumSize _value{ 0u };
};
%template(EntityCapabilitiesss) EnumBitfield2<la::avdecc::entity::EntityCapability, std::uint32_t>;
//%typemap(csbase) EnumBitfield2<la::avdecc::entity::EntityCapability, std::uint32_t> "uint"
%apply EnumBitfield2<la::avdecc::entity::EntityCapability, std::uint32_t> { la::avdecc::utils::EnumBitfield<la::avdecc::entity::EntityCapability> };
#endif
// TEMP TO TEST IF EntityCapability is correctly wrapped
%inline %{
	la::avdecc::entity::EntityCapabilities getCapa() noexcept
	{
		return la::avdecc::entity::EntityCapabilities{la::avdecc::entity::EntityCapability::AemSupported};
	}
%}

DEFINE_ENTITY_ENUM_BITFIELD_CLASS(TalkerCapabilities, TalkerCapability, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(ListenerCapabilities, ListenerCapability, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(ControllerCapabilities, ControllerCapability, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(ConnectionFlags, ConnectionFlag, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(StreamFlags, StreamFlag, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(JackFlags, JackFlag, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(AvbInterfaceFlags, AvbInterfaceFlag, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(ClockSourceFlags, ClockSourceFlag, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(PortFlags, PortFlag, "ushort")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(StreamInfoFlags, StreamInfoFlag, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(StreamInfoFlagsEx, StreamInfoFlagEx, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(AvbInfoFlags, AvbInfoFlag, "byte")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(EntityCounterValidFlags, EntityCounterValidFlag, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(AvbInterfaceCounterValidFlags, AvbInterfaceCounterValidFlag, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(ClockDomainCounterValidFlags, ClockDomainCounterValidFlag, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(StreamInputCounterValidFlags, StreamInputCounterValidFlag, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(StreamOutputCounterValidFlags, StreamOutputCounterValidFlag, "uint")
DEFINE_ENTITY_ENUM_BITFIELD_CLASS(MilanInfoFeaturesFlags, MilanInfoFeaturesFlag, "uint")

// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

%include "la/avdecc/internals/entityEnums.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes


////////////////////////////////////////
// Protocol Defines
////////////////////////////////////////
%define DEFINE_PROTOCOL_CLASS(name)
	%nspace la::avdecc::protocol::name;
	%rename("%s") la::avdecc::protocol::name; // Unignore class
	%ignore la::avdecc::protocol::name::name(); // Ignore default constructor
	%rename("toString") la::avdecc::protocol::name::operator std::string() const noexcept;
%enddef

// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

// TODO: Would be easier to map these types to the underlying integer type (but how to do it?)
DEFINE_PROTOCOL_CLASS(AdpMessageType)
DEFINE_PROTOCOL_CLASS(AecpMessageType)
DEFINE_PROTOCOL_CLASS(AecpStatus)
DEFINE_PROTOCOL_CLASS(AemAecpStatus)
%ignore la::avdecc::protocol::AemAecpStatus::AemAecpStatus(AecpStatus const status) noexcept; // Ignore constructor
DEFINE_PROTOCOL_CLASS(AemCommandType)
DEFINE_PROTOCOL_CLASS(AemAcquireEntityFlags)
DEFINE_PROTOCOL_CLASS(AemLockEntityFlags)
DEFINE_PROTOCOL_CLASS(AaMode)
DEFINE_PROTOCOL_CLASS(AaAecpStatus)
DEFINE_PROTOCOL_CLASS(MvuAecpStatus)
DEFINE_PROTOCOL_CLASS(MvuCommandType)
DEFINE_PROTOCOL_CLASS(AcmpMessageType)
DEFINE_PROTOCOL_CLASS(AcmpStatus)

%include "la/avdecc/internals/protocolDefines.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes

// Define templates
//%template(AdpMessageTypedDefine) la::avdecc::utils::TypedDefine<la::avdecc::protocol::AdpMessageType, std::uint8_t>; // TODO: Ask how to correctly define a parent class that is a template


////////////////////////////////////////
// Entity Model
////////////////////////////////////////
// We need to import NetworkInterfaces
%import "la/networkInterfaceHelper/networkInterfaceHelper.i"

// Define some macros
%define DEFINE_AEM_DESCRIPTOR(name)
	%nspace la::avdecc::entity::model::name;
	%rename("%s") la::avdecc::entity::model::name; // Unignore class
%enddef
%define DEFINE_AEM_STRUCT(name)
	%nspace la::avdecc::entity::model::name;
	%rename("%s") la::avdecc::entity::model::name; // Unignore class
	%rename("isEqual") operator==(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
	%rename("isDifferent") operator!=(name const& lhs, name const& rhs) noexcept; // Not put in a namespace https://github.com/swig/swig/issues/2459
%enddef

// Define optionals
//DEFINE_OPTIONAL_CLASS(la::avdecc::entity, StreamInfoFlagsEx, OptStreamInfoFlagsEx, 0u)
DEFINE_OPTIONAL_CLASS(la::avdecc::entity::model, ProbingStatus, OptProbingStatus, la.avdecc.entity.model.ProbingStatus.Disabled)
DEFINE_OPTIONAL_CLASS(la::avdecc::protocol, AcmpStatus, OptAcmpStatus, la.avdecc.protocol.AcmpStatus.Success)

// Bind structs and classes
%rename($ignore, %$isclass) ""; // Ignore all structs/classes, manually re-enable

DEFINE_AEM_DESCRIPTOR(EntityDescriptor);
DEFINE_AEM_DESCRIPTOR(ConfigurationDescriptor);
DEFINE_AEM_DESCRIPTOR(AudioUnitDescriptor);
DEFINE_AEM_DESCRIPTOR(StreamDescriptor);
DEFINE_AEM_DESCRIPTOR(JackDescriptor);
DEFINE_AEM_DESCRIPTOR(AvbInterfaceDescriptor);
DEFINE_AEM_DESCRIPTOR(ClockSourceDescriptor);
DEFINE_AEM_DESCRIPTOR(MemoryObjectDescriptor);
DEFINE_AEM_DESCRIPTOR(LocaleDescriptor);
DEFINE_AEM_DESCRIPTOR(StringsDescriptor);
DEFINE_AEM_DESCRIPTOR(StreamPortDescriptor);
DEFINE_AEM_DESCRIPTOR(ExternalPortDescriptor);
DEFINE_AEM_DESCRIPTOR(InternalPortDescriptor);
DEFINE_AEM_DESCRIPTOR(AudioClusterDescriptor);
DEFINE_AEM_DESCRIPTOR(AudioMapDescriptor);
DEFINE_AEM_DESCRIPTOR(ControlDescriptor);
DEFINE_AEM_DESCRIPTOR(ClockDomainDescriptor);
DEFINE_AEM_STRUCT(StreamInfo);
DEFINE_AEM_STRUCT(AvbInfo);
DEFINE_AEM_STRUCT(AsPath);

// Some ignores
%ignore la::avdecc::entity::model::makeEntityModelID; // Ignore, not needed
%ignore la::avdecc::entity::model::splitEntityModelID; // Ignore, not needed

%include "la/avdecc/internals/entityModel.hpp"
%rename("%s", %$isclass) ""; // Undo the ignore all structs/classes

// Define templates
%template(DescriptorCounts) std::unordered_map<la::avdecc::entity::model::DescriptorType, std::uint16_t, la::avdecc::utils::EnumClassHash>;
%template(Strings) std::array<la::avdecc::entity::model::AvdeccFixedString, 7>;
//%template(ClockSources) std::vector<la::avdecc::entity::model::ClockSourceIndex>; // Not compiling in C# (maybe need to %apply as ushort all descriptor indexes?)
%template(SamplingRates) std::set<la::avdecc::entity::model::SamplingRate>;
%template(StreamFormats) std::set<la::avdecc::entity::model::StreamFormat>;
%template(RedundantStreamIndexes) std::set<la::avdecc::entity::model::StreamIndex>;