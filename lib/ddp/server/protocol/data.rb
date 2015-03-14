require 'celluloid'

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

				def handle_sub(id, name, params)
					params ||= []
					query = api.collection_query(name, *params)
					subscription = subscriptions[id] = Subscription.new(self, id, name, query)
					subscription.async.start
					send_ready([id])
				rescue => e
					send_error_result(id, e)
				end

				def subscription_update(id, old_value, new_value)
					subscription_name = @subscriptions[id].name
					new_value_id = new_value['id']
					old_value_id = old_value['id']

					return send_added(subscription_name, new_value_id, new_value) if old_value.nil?
					return send_removed(subscription_name, old_value_id) if new_value.nil?

					send_changed(subscription_name, old_value_id, new_value, old_value.keys - new_value.keys)
				end

				def handle_unsub(id)
					subscription = @subscriptions.delete(id)
					subscription.stop unless subscription.nil?
					send_nosub(id)
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

				# Actor that asynchronously monitors a collection
				class Subscription
					include Celluloid

					attr_reader :name, :stopped, :listener, :query, :id
					alias_method :stopped?, :stopped

					def initialize(listener, id, name, query)
						@stopped = false
						@name = name
						@listener = listener
						@id = id
						@query = query
					end

					def start
						query.call do |old_value, new_value|
							listener.subscription_update(id, old_value, new_value)
							break if stopped?
						end
					end

					def stop
						@stopped = true
					end
				end
			end
		end
	end
end
