package data
{
	import com.hurlant.util.*;
	import com.hurlant.crypto.*;
	import com.hurlant.crypto.symmetric.*;
	
	import flash.utils.ByteArray;

	/**
	 * The GameEncryption class uses the AS3Crypto library by Henri Torgemane.
	 * http://code.google.com/p/as3crypto/
	 * 
	 * We implement a simple AES encryption using CBC mode.
	 */
	public class GameEncryption
	{
		public static var encryptionKey:String;

		/**
		 * Array of keys used to create or initialize
		 * the encryption key for the game.
		 */
		protected static var key:Array = new Array(
			'4eceed3c1d6af268b0a1149823827ec5',
			'5074535a0c40bb1482e630084025409b',
			'1de9c1bec7517335958171a50b789de2',
			'9fdfef4b6a0650071cbf345e28dffb48',
			'4e51c52724777ac17a6c011372069f32' );

		/**
		 * This array is used to create or initialize the
		 * encryption key for all games.
		 */
		protected static var sequence:Array = new Array( 4, 0, 2, 2, 3, 4, 1 );

		public function GameEncryption()
		{
		}

		/**
		 * Gets the actual encryption key needed for communication
		 * with the server by decrypting a password. The sequence
		 * of keys used to decrypt the actul encryption key are in
		 * the sequence array.
		 */
		public static function getEncryptionKey( password:String ):String
		{
			var start:uint = GameEncryption.sequence.length - 1;

			for ( var i:int = start; i >= 0; i-- ) {

				var idx:uint	= GameEncryption.sequence[ i ];
				var key:String	= GameEncryption.key[ idx ];
				password = GameEncryption.decrypt( password, key );
			}

			return password;
		}

		/**
		 * Create a new encrypted key (PASSWORD) to hide the actual
		 * encryption key so no one can view it. The password is created
		 * by sending the actual encryption key through a series of
		 * encryptions using keys from the key array. The sequence of
		 * encryptions is determined by the sequence array.
		 */
		public static function createEncryptedKey( key:String ):String
		{
			var encrypted:String = key;
			var len:uint = GameEncryption.sequence.length;

			for ( var i:uint = 0; i < len; i++ ) {

				var idx:uint	= GameEncryption.sequence[ i ];
				key				= GameEncryption.key[ idx ];
				encrypted		= GameEncryption.encrypt( encrypted, key );
			}

			return encrypted;
		}

		/**
		 * Provides a possiblity to create an encrypted
		 * key (password) for a game. We do this so the
		 * actual encryption key isn't publicly viewable
		 * when the SWF file is decompiled.
		 * 
		 * You can just use createEncryptedKey(), but with this
		 * method you can ensure that the decrypted version matches
		 * the original key. It also creates the actual PASSWORD
		 * constant for the game data, which you can copy/paste
		 * into your game.
		 * 
		 * Make sure trace is active when using this method.
		 */
		public static function initEncryptionKey( key:String ):void
		{
			var encrypted:String = GameEncryption.createEncryptedKey( key );
			var decrypted:String = GameEncryption.getEncryptionKey( encrypted );

			const NUM_CHARS:uint = 32;

			trace( 'GameEncryption() password: ' + encrypted );
			trace.addLine( 'GameEncryption() decrypted: ' + decrypted );
			trace.addLine( 'GameEncryption() ***************************************' );
			trace.addLine( 'protected static const PASSWORD:String =' );

			var i:uint = 0;

			loop: while ( ( i * NUM_CHARS ) < encrypted.length ) {

				var part:String = '';

				for ( var k:uint = 0; k < NUM_CHARS; k++ ) {

					var pos:uint = ( i * NUM_CHARS ) + k;

					part += encrypted.substr( pos, 1 );

					if ( ( pos + 1 ) >= encrypted.length ) {

						trace.addLine( "'" + part + "';" );
						break loop;
					}
				}

				trace.addLine( "'" + part + "' +" );
				i++;
			}

			trace.addLine( 'GameEncryption() ***************************************' );
		}

		/** 
		 * Encrypt a text using AES encryption in CBC mode of operation
		 *
		 * Unicode multi-byte character safe
		 *
		 * @param plaintext Source text to be encrypted
		 * @param password  The password to use to generate a key
		 * @returns         Encrypted text
		 */
		public static function encrypt( txt:String, key:String = '' ):String
		{
			var keyData:ByteArray	= Hex.toArray( Hex.fromString( key ) );
			var txtData:ByteArray	= Hex.toArray( Hex.fromString( txt ) );
			var pad:IPad			= new NullPad;
			var mode:ICipher		= Crypto.getCipher( 'simple-aes-cbc', keyData, pad );

			pad.setBlockSize( mode.getBlockSize() );
			mode.encrypt( txtData );

			return Base64.encodeByteArray( txtData );
		}

		/** 
		 * Decrypt a text encrypted by AES in CBC mode of operation
		 *
		 * @param txt		Source text to be encrypted
		 * @param password 	The password to use to generate a key
		 * @returns			Decrypted text
		 */
		public static function decrypt( txt:String, key:String = '' ):String
		{
			var keyData:ByteArray	= Hex.toArray( Hex.fromString( key ) );
			var txtData:ByteArray	= Base64.decodeToByteArray( txt );
			var pad:IPad			= new NullPad;
			var mode:ICipher		= Crypto.getCipher( 'simple-aes-cbc', keyData, pad );

			pad.setBlockSize( mode.getBlockSize() );
			mode.decrypt( txtData );

			txtData.position = 0;
			return txtData.readUTFBytes( txtData.bytesAvailable );
		}
	}
}
