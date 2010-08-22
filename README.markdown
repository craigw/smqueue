SMQueue
=======

A simple interface to message queues.


Rationale
---------

Just about every queueing system under the sun provides it's own usually
rather complex interface. Coding to one of these interfaces couples your
code with the queueing system that's deployed. All we really want from a
queueing system is a way to get messages from a source and a way to put
messages on a destination.


Programming with SMQueue
------------------------

    # Normally these are configured somewhere not in the code ie by the
    # sysadmin on deployment. Maybe they're read from a configuration file
    # or similar, but that's outside the scope of this project.
    broker_uri = "activemq:stomp://username:password@mq.example.com:61613"
    channel_name = "/queue/example.foo"

    mq = SMQueue.new broker_uri
    channel = mq.channel channel_name

    # Get one message.
    message = channel.get # => [ headers = {}, "body" ]

    # To get messages until the Ruby VM dies do this:
    channel.get do |headers, body|
      # ...
    end

    # Put a message onto the channel like this:
    channel.put headers, body

    # Close the channel when you're done
    channel.close


Contributing
------------

  * Fork the project.
  * Make your feature addition or bug fix.
  * Add tests for it. This is important so I don't break it in a
    future version unintentionally.
  * Commit, do not mess with the Rakefile or SMQueue::VERSION. If you
    want to have your own version, that is fine but bump version in a
    commit by itself I can ignore when I pull.
  * Send me a pull request. Bonus points for topic branches.


Authors
-------

  * Sean O'Halpin
  * Craig R Webster <http://barkingiguana.com/>


License
-------

Released under the MIT licence. See the LICENSE file for details.