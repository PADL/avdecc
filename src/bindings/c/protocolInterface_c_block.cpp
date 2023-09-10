/*
* Copyright (C) 2016-2023, L-Acoustics and its contributors

* This file is part of LA_avdecc.

* LA_avdecc is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* LA_avdecc is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Lesser General Public License for more details.

* You should have received a copy of the GNU Lesser General Public License
* along with LA_avdecc.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
* @file protocolInterface_c_block.cpp
* @author Christophe Calmejane
* @brief C block bindings for la::avdecc::protocol::ProtocolInterface.
*/

#include <la/avdecc/internals/protocolInterface.hpp>
#include "la/avdecc/avdecc.h"
#include "localEntity_c.hpp"
#include "utils.hpp"

#if __BLOCKS__
extern la::avdecc::bindings::HandleManager<la::avdecc::protocol::ProtocolInterface::UniquePointer> s_ProtocolInterfaceManager;

class BlockObserver final : public la::avdecc::protocol::ProtocolInterface::Observer
{
public:
	BlockObserver(avdecc_protocol_interface_block_observer_p const observer, LA_AVDECC_PROTOCOL_INTERFACE_HANDLE const handle)
		: _observer(*observer)
		, _handle(handle)
	{
		_Block_copy(_observer.onTransportError);
		_Block_copy(_observer.onLocalEntityOnline);
		_Block_copy(_observer.onLocalEntityOffline);
		_Block_copy(_observer.onLocalEntityUpdated);
		_Block_copy(_observer.onRemoteEntityOnline);
		_Block_copy(_observer.onRemoteEntityOffline);
		_Block_copy(_observer.onRemoteEntityUpdated);
		_Block_copy(_observer.onAecpAemCommand);
		_Block_copy(_observer.onAecpAemUnsolicitedResponse);
		_Block_copy(_observer.onAecpAemIdentifyNotification);
		_Block_copy(_observer.onAcmpCommand);
		_Block_copy(_observer.onAcmpResponse);
		_Block_copy(_observer.onAdpduReceived);
		_Block_copy(_observer.onAemAecpduReceived);
		_Block_copy(_observer.onMvuAecpduReceived);
		_Block_copy(_observer.onAcmpduReceived);
	}

        ~BlockObserver()
	{
		_Block_release(_observer.onTransportError);
		_Block_release(_observer.onLocalEntityOnline);
		_Block_release(_observer.onLocalEntityOffline);
		_Block_release(_observer.onLocalEntityUpdated);
		_Block_release(_observer.onRemoteEntityOnline);
		_Block_release(_observer.onRemoteEntityOffline);
		_Block_release(_observer.onRemoteEntityUpdated);
		_Block_release(_observer.onAecpAemCommand);
		_Block_release(_observer.onAecpAemUnsolicitedResponse);
		_Block_release(_observer.onAecpAemIdentifyNotification);
		_Block_release(_observer.onAcmpCommand);
		_Block_release(_observer.onAcmpResponse);
		_Block_release(_observer.onAdpduReceived);
		_Block_release(_observer.onAemAecpduReceived);
		_Block_release(_observer.onMvuAecpduReceived);
		_Block_release(_observer.onAcmpduReceived);
	}

	const avdecc_protocol_interface_block_observer_s *getObserver() const noexcept
	{
		return &_observer;
	}

private:
	// la::avdecc::protocol::ProtocolInterface::Observer overrides
	/* **** Global notifications **** */
	virtual void onTransportError(la::avdecc::protocol::ProtocolInterface* const /*pi*/) noexcept override
	{
		la::avdecc::utils::invokeProtectedHandler(_observer.onTransportError, _handle);
	}

	/* **** Discovery notifications **** */
	virtual void onLocalEntityOnline(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::entity::Entity const& entity) noexcept override
	{
		auto const e = la::avdecc::bindings::fromCppToC::make_entity(entity);
		la::avdecc::utils::invokeProtectedHandler(_observer.onLocalEntityOnline, _handle, &e.entity);
	}
	virtual void onLocalEntityOffline(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::UniqueIdentifier const entityID) noexcept override
	{
		la::avdecc::utils::invokeProtectedHandler(_observer.onLocalEntityOffline, _handle, entityID);
	}
	virtual void onLocalEntityUpdated(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::entity::Entity const& entity) noexcept override
	{
		auto const e = la::avdecc::bindings::fromCppToC::make_entity(entity);
		la::avdecc::utils::invokeProtectedHandler(_observer.onLocalEntityUpdated, _handle, &e.entity);
	}
	virtual void onRemoteEntityOnline(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::entity::Entity const& entity) noexcept override
	{
		auto const e = la::avdecc::bindings::fromCppToC::make_entity(entity);
		la::avdecc::utils::invokeProtectedHandler(_observer.onRemoteEntityOnline, _handle, &e.entity);
	}
	virtual void onRemoteEntityOffline(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::UniqueIdentifier const entityID) noexcept override
	{
		la::avdecc::utils::invokeProtectedHandler(_observer.onRemoteEntityOffline, _handle, entityID);
	}
	virtual void onRemoteEntityUpdated(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::entity::Entity const& entity) noexcept override
	{
		auto const e = la::avdecc::bindings::fromCppToC::make_entity(entity);
		la::avdecc::utils::invokeProtectedHandler(_observer.onRemoteEntityUpdated, _handle, &e.entity);
	}

	/* **** AECP notifications **** */
	virtual void onAecpCommand(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::Aecpdu const& aecpdu) noexcept override
	{
		static auto const s_Dispatch = std::unordered_map<la::avdecc::protocol::AecpMessageType, std::function<void(BlockObserver* const obs, la::avdecc::protocol::Aecpdu const& aecpdu)>, la::avdecc::protocol::AecpMessageType::Hash>{
			{ la::avdecc::protocol::AecpMessageType::AemCommand,
				[](BlockObserver* const obs, la::avdecc::protocol::Aecpdu const& aecpdu)
				{
					auto aecp = la::avdecc::bindings::fromCppToC::make_aem_aecpdu(static_cast<la::avdecc::protocol::AemAecpdu const&>(aecpdu));
					la::avdecc::utils::invokeProtectedHandler(obs->_observer.onAecpAemCommand, obs->_handle, &aecp);
				} },
			{ la::avdecc::protocol::AecpMessageType::AddressAccessCommand,
				[](BlockObserver* const /*obs*/, la::avdecc::protocol::Aecpdu const& /*aecpdu*/)
				{
					//
				} },
			{ la::avdecc::protocol::AecpMessageType::VendorUniqueResponse,
				[](BlockObserver* const /*obs*/, la::avdecc::protocol::Aecpdu const& /*aecpdu*/)
				{
					//
				} },
		};

		auto const& it = s_Dispatch.find(aecpdu.getMessageType());
		if (it != s_Dispatch.end())
		{
			it->second(this, aecpdu);
		}
	}
	virtual void onAecpAemUnsolicitedResponse(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::AemAecpdu const& aecpdu) noexcept override
	{
		auto aecp = la::avdecc::bindings::fromCppToC::make_aem_aecpdu(aecpdu);
		la::avdecc::utils::invokeProtectedHandler(_observer.onAecpAemUnsolicitedResponse, _handle, &aecp);
	}
	virtual void onAecpAemIdentifyNotification(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::AemAecpdu const& aecpdu) noexcept override
	{
		auto aecp = la::avdecc::bindings::fromCppToC::make_aem_aecpdu(aecpdu);
		la::avdecc::utils::invokeProtectedHandler(_observer.onAecpAemIdentifyNotification, _handle, &aecp);
	}

	/* **** ACMP notifications **** */
	virtual void onAcmpCommand(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::Acmpdu const& acmpdu) noexcept override
	{
		auto acmp = la::avdecc::bindings::fromCppToC::make_acmpdu(acmpdu);
		la::avdecc::utils::invokeProtectedHandler(_observer.onAcmpCommand, _handle, &acmp);
	}
	virtual void onAcmpResponse(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::Acmpdu const& acmpdu) noexcept override
	{
		auto acmp = la::avdecc::bindings::fromCppToC::make_acmpdu(acmpdu);
		la::avdecc::utils::invokeProtectedHandler(_observer.onAcmpResponse, _handle, &acmp);
	}

	/* **** Low level notifications (not supported by all kinds of ProtocolInterface), triggered before processing the pdu **** */
	virtual void onAdpduReceived(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::Adpdu const& adpdu) noexcept override
	{
		auto acmp = la::avdecc::bindings::fromCppToC::make_adpdu(adpdu);
		la::avdecc::utils::invokeProtectedHandler(_observer.onAdpduReceived, _handle, &acmp);
	}
	virtual void onAecpduReceived(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::Aecpdu const& aecpdu) noexcept override
	{
		static auto const s_Dispatch = std::unordered_map<la::avdecc::protocol::AecpMessageType, std::function<void(BlockObserver* const obs, la::avdecc::protocol::Aecpdu const& aecpdu)>, la::avdecc::protocol::AecpMessageType::Hash>{
			{ la::avdecc::protocol::AecpMessageType::AemCommand,
				[](BlockObserver* const obs, la::avdecc::protocol::Aecpdu const& aecpdu)
				{
					auto aecp = la::avdecc::bindings::fromCppToC::make_aem_aecpdu(static_cast<la::avdecc::protocol::AemAecpdu const&>(aecpdu));
					la::avdecc::utils::invokeProtectedHandler(obs->_observer.onAemAecpduReceived, obs->_handle, &aecp);
				} },
			{ la::avdecc::protocol::AecpMessageType::AddressAccessCommand,
				[](BlockObserver* const /*obs*/, la::avdecc::protocol::Aecpdu const& /*aecpdu*/)
				{
					//
				} },
			{ la::avdecc::protocol::AecpMessageType::VendorUniqueResponse,
				[](BlockObserver* const obs, la::avdecc::protocol::Aecpdu const& /*aecpdu*/)
				{
					la::avdecc::utils::invokeProtectedHandler(obs->_observer.onMvuAecpduReceived, obs->_handle, nullptr); // TODO: Create correct VU
				} },
		};

		auto const& it = s_Dispatch.find(aecpdu.getMessageType());
		if (it != s_Dispatch.end())
		{
			it->second(this, aecpdu);
		}
	}
	virtual void onAcmpduReceived(la::avdecc::protocol::ProtocolInterface* const /*pi*/, la::avdecc::protocol::Acmpdu const& acmpdu) noexcept override
	{
		auto acmp = la::avdecc::bindings::fromCppToC::make_acmpdu(acmpdu);
		la::avdecc::utils::invokeProtectedHandler(_observer.onAcmpduReceived, _handle, &acmp);
	}

	// Private members
	avdecc_protocol_interface_block_observer_s _observer{ };
	LA_AVDECC_PROTOCOL_INTERFACE_HANDLE _handle{ LA_AVDECC_INVALID_HANDLE };
	DECLARE_AVDECC_OBSERVER_GUARD(BlockObserver);
};

static la::avdecc::bindings::HandleManager<BlockObserver*> s_ProtocolInterfaceBlockObserverManager{};

LA_AVDECC_BINDINGS_C_API avdecc_protocol_interface_error_t LA_AVDECC_BINDINGS_C_CALL_CONVENTION LA_AVDECC_ProtocolInterface_registerObserver_block(LA_AVDECC_PROTOCOL_INTERFACE_HANDLE const handle, avdecc_protocol_interface_block_observer_p const observer)
{
	try
	{
		auto& obj = s_ProtocolInterfaceManager.getObject(handle);

		try
		{
			obj.registerObserver(&s_ProtocolInterfaceBlockObserverManager.getObject(s_ProtocolInterfaceBlockObserverManager.createObject(observer, handle)));
		}
		catch (...) // Same observer registered twice
		{
			return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_invalid_parameters);
		}
	}
	catch (...)
	{
		return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_invalid_protocol_interface_handle);
	}

	return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_no_error);
}

LA_AVDECC_BINDINGS_C_API avdecc_protocol_interface_error_t LA_AVDECC_BINDINGS_C_CALL_CONVENTION LA_AVDECC_ProtocolInterface_unregisterObserver_block(LA_AVDECC_PROTOCOL_INTERFACE_HANDLE const handle, avdecc_protocol_interface_block_observer_p const observer)
{
	try
	{
		auto& obj = s_ProtocolInterfaceManager.getObject(handle);

		// Search the observer matching our ProtocolInterface observer
		for (auto const& obsKV : s_ProtocolInterfaceBlockObserverManager.getObjects())
		{
			auto const& obs = obsKV.second;
			if (obs->getObserver() == observer)
			{
				obj.unregisterObserver(obs.get());
				s_ProtocolInterfaceBlockObserverManager.destroyObject(obsKV.first);
				break;
			}
		}
	}
	catch (...)
	{
		return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_invalid_protocol_interface_handle);
	}

	return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_no_error);
}

LA_AVDECC_BINDINGS_C_API avdecc_protocol_interface_error_t LA_AVDECC_BINDINGS_C_CALL_CONVENTION LA_AVDECC_ProtocolInterface_sendAemAecpCommand_block(LA_AVDECC_PROTOCOL_INTERFACE_HANDLE const handle, avdecc_protocol_aem_aecpdu_cp const aecpdu, avdecc_protocol_interfaces_send_aem_aecp_command_block const onResultBlock)
{
	auto onResult = la::avdecc::utils::Block(onResultBlock);

	try
	{
		auto& obj = s_ProtocolInterfaceManager.getObject(handle);
		return la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(obj.sendAecpCommand(la::avdecc::bindings::fromCToCpp::make_aem_aecpdu_unique(aecpdu),
			[onResult](la::avdecc::protocol::Aecpdu const* const response, la::avdecc::protocol::ProtocolInterface::Error const error)
			{
				if (!error)
				{
					if (AVDECC_ASSERT_WITH_RET(response->getMessageType() == la::avdecc::protocol::AecpMessageType::AemResponse, "Received AECP is NOT an AEM Response"))
					{
						auto aecpdu = la::avdecc::bindings::fromCppToC::make_aem_aecpdu(static_cast<la::avdecc::protocol::AemAecpdu const&>(*response));
						la::avdecc::utils::invokeProtectedHandler(onResult, &aecpdu, la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(error));
					}
					else
					{
						la::avdecc::utils::invokeProtectedHandler(onResult, nullptr, static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_internal_error));
					}
				}
				else
				{
					la::avdecc::utils::invokeProtectedHandler(onResult, nullptr, la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(error));
				}
			}));
	}
	catch (...)
	{
		return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_internal_error);
	}
}

LA_AVDECC_BINDINGS_C_API avdecc_protocol_interface_error_t LA_AVDECC_BINDINGS_C_CALL_CONVENTION LA_AVDECC_ProtocolInterface_sendMvuAecpCommand_block(LA_AVDECC_PROTOCOL_INTERFACE_HANDLE const handle, avdecc_protocol_mvu_aecpdu_cp const aecpdu, avdecc_protocol_interfaces_send_mvu_aecp_command_block const onResultBlock)
{
	auto onResult = la::avdecc::utils::Block(onResultBlock);

	try
	{
		auto& obj = s_ProtocolInterfaceManager.getObject(handle);
		return la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(obj.sendAecpCommand(la::avdecc::bindings::fromCToCpp::make_mvu_aecpdu_unique(aecpdu),
			[onResult](la::avdecc::protocol::Aecpdu const* const response, la::avdecc::protocol::ProtocolInterface::Error const error)
			{
				if (!error)
				{
					if (AVDECC_ASSERT_WITH_RET(response->getMessageType() == la::avdecc::protocol::AecpMessageType::VendorUniqueResponse, "Received AECP is NOT a VU Response"))
					{
						auto const& vuaecpdu = static_cast<la::avdecc::protocol::VuAecpdu const&>(*response);
						if (AVDECC_ASSERT_WITH_RET(vuaecpdu.getProtocolIdentifier() == la::avdecc::protocol::MvuAecpdu::ProtocolID, "Received AECP is NOT a MVU Response"))
						{
							auto aecpdu = la::avdecc::bindings::fromCppToC::make_mvu_aecpdu(static_cast<la::avdecc::protocol::MvuAecpdu const&>(*response));
							la::avdecc::utils::invokeProtectedHandler(onResult, &aecpdu, la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(error));
						}
						else
						{
							la::avdecc::utils::invokeProtectedHandler(onResult, nullptr, static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_internal_error));
						}
					}
					else
					{
						la::avdecc::utils::invokeProtectedHandler(onResult, nullptr, static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_internal_error));
					}
				}
				else
				{
					la::avdecc::utils::invokeProtectedHandler(onResult, nullptr, la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(error));
				}
			}));
	}
	catch (...)
	{
		return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_internal_error);
	}
}

LA_AVDECC_BINDINGS_C_API avdecc_protocol_interface_error_t LA_AVDECC_BINDINGS_C_CALL_CONVENTION LA_AVDECC_ProtocolInterface_sendAcmpCommand_block(LA_AVDECC_PROTOCOL_INTERFACE_HANDLE const handle, avdecc_protocol_acmpdu_cp const acmpdu, avdecc_protocol_interfaces_send_acmp_command_block const onResultBlock)
{
	auto onResult = la::avdecc::utils::Block(onResultBlock);

	try
	{
		auto& obj = s_ProtocolInterfaceManager.getObject(handle);
		return la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(obj.sendAcmpCommand(la::avdecc::bindings::fromCToCpp::make_acmpdu_unique(acmpdu),
			[onResult](la::avdecc::protocol::Acmpdu const* const response, la::avdecc::protocol::ProtocolInterface::Error const error)
			{
				if (!error)
				{
					auto acmpdu = la::avdecc::bindings::fromCppToC::make_acmpdu(*response);
					la::avdecc::utils::invokeProtectedHandler(onResult, &acmpdu, la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(error));
				}
				else
				{
					la::avdecc::utils::invokeProtectedHandler(onResult, nullptr, la::avdecc::bindings::fromCppToC::convertProtocolInterfaceErrorCode(error));
				}
			}));
	}
	catch (...)
	{
		return static_cast<avdecc_protocol_interface_error_t>(avdecc_protocol_interface_error_internal_error);
	}
}
#endif /* __BLOCKS__ */
