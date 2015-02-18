module DDP
	module Server
		module Protocol
			# Protocol regarding handling data subscriptions
			module Data
				def handle_data
					case @message['msg']
					when 'sub'
						handle_sub(@message['id'], @message['name'], @message['params'])
						true
					when 'unsub'
						handle_unsub(@message['id'])
						true
					else
						false
					end
				end

				def handle_sub(_id, _name, _params)
					raise 'Must be overridden'
				end

				def handle_unsub(_id)
					raise 'Must be overridden'
				end

				def send_nosub(id, error = nil)
					message = { msg: 'nosub', id: id }
					message.merge!(error: error) if error
					write_message message
				end

				def send_added(collection, id, fields = nil)
					message = { msg: 'added', id: id, collection: collection }
					message.merge!(fields: fields) if fields
					write_message message
				end

				def send_changed(collection, id, fields = nil, cleared = nil)
					message = { msg: 'changed', id: id, collection: collection }
					message.merge!(fields: fields) if fields
					message.merge!(cleared: cleared) if cleared
					write_message message
				end

				def send_removed(collection, id)
					write_message msg: 'removed', collection: collection, id: id
				end

				def send_ready(subs)
					write_message msg: 'ready', subs: subs
				end

				def send_added_before(collection, id, fields = nil, before = nil)
					message = { msg: 'addedBefore', id: id, collection: collection, before: before }
					message.merge!(fields: fields) if fields
					write_message message
				end

				def send_moved_before(collection, id, before = nil)
					write_message msg: 'movedBefore', id: id, collection: collection, before: before
				end
			end
		end
	end
end
