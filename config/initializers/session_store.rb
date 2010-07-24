# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fas2rdf_session',
  :secret      => '3f7f554669ca45f1aeacec93e1b6e26c04f038fc10f3f166033a258dcb7c4aebd6da68a607c050d55316c2149bfd2799cc512161b36a56c2b4ff7786d0c257e5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
