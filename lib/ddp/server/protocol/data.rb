module DDP
	module Server
		module Protocol
			# Protocol regarding handling data subscriptions
			module Data
				def handle_data
					case @message['msg']
					when 'sub'
						handle_sub
						true
					when 'unsub'
						handle_unsub
						true
					else
						false
					end
				end

				def handle_sub
					raise 'Must be overridden'
				end

				def handle_unsub
					raise 'Must be overridden'
				end

				def nosub(id, error = nil)
					message = { msg: 'nosub', id: id }
					message.merge!(error: error) if error
					write_message message
				end

				def added(collection, id, fields = nil)
					message = { msg: 'added', id: id, collection: collection }
					message.merge!(fields: fields) if fields
					write_message message
				end

				def changed(collection, id, fields = nil, cleared = nil)
					message = { msg: 'changed', id: id, collection: collection }
					message.merge!(fields: fields) if fields
					message.merge!(cleared: cleared) if cleared
					write_message message
				end

				def removed(collection, id)
					write_message msg: 'removed', collection: collection, id: id
				end

				def ready(subs)
					write_message msg: 'ready', subs: subs
				end

				def added_before(collection, id, fields = nil, before = nil)
					message = { msg: 'addedBefore', id: id, collection: collection, before: before }
					message.merge!(fields: fields) if fields
					write_message message
				end

				def moved_before(collection, id, before = nil)
					write_message msg: 'movedBefore', id: id, collection: collection, before: before
				end
			end
		end
	end
end
