# Cipher

A tool for securely sending and receiving sensitive information ('secrets') such as passphrases, license keys, API credentials, or access tokens, with zero-knowledge end-to-end encryption.

Unlike most "secret sharing" tools, **Cipher never touches your secrets**--not even in encrypted form.

## Architecture

Cipher is a key-provider and policy-enforcer service.

- The backend only stores a *decryption key*, along with usage rules (such as expiry date and how many times it may be used).
- The secret itself is encrypted and decrypted exclusively on the client-side, and transmitted (in encrypted form) as a base64-encoded URL parameter.

The full flow is as follows:

1. Alice wants to send a passphrase to Bob. She enters the passphrase into Cipher.
2. Cipher generates a new keypair consisting of a key ID (`kid`) and cryptographically secure symetrical key.
3. Alice's browser uses this key to encrypt the secret and builds an URL containing the `kid` and the encrypted secret in base64 encoded form.
4. Alice now sends this URL to Bob using her platform of choice (eg. E-mail, Signal, WhatsApp etc.)
5. Bob opens the URL in his browser, which asks Cipher about the `kid`.
6. Cipher checks whether the keypair for the given `kid` has not yet expired, and if the pair has not yet expired (and still has uses left), sends the decryption key to the browser.
7. The browser uses this decryption key to decrypt the secret, and shows it to Bob.

Expired and stale keys are periodically pruned from the database.

## Rationale

Exchanging sensitive information via chat or email is generally known to be unsafe, because these types of services are often insufficiently secured (often easily intercepted) and particularly prone to XXX. **Assume all email conversations will eventually be compromised.**

This introduces the need for a secure channel for exchanging these kind of details, often provided by a trusted third party. However, past incidents have proven that these services, posessing a vast database of highly sensitive information, quickly become a particularly attractive target for attackers.

Thus, the following requirements emerge:

- We want leaked chat and email conversations to be useless to hackers.
- We want leaked databases from this service to be useless to hackers.

Since the Cipher only knows (temporary) decryption keys, in the unlikely event of a hack, the database would be near useless to the attackers. Additionally, all encryption is done in human-readable client-side JavaScript, which can be inspected and audited by simply opening 'View Source'.
