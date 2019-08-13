package com.crow.school_schedule;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity
{
	private static final String CHANNEL = "com.crow.school_schedule/refresh";

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		GeneratedPluginRegistrant.registerWith(this);

		new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler((methodCall, result) ->
			{
				// This is invoked on the main thread

				/*
				 * How this works:
				 * call.method includes the actual call we did, so for example
				 * "startRefresh" or "stopRefresh" etc. the result of it is then
				 * returned as result.success(<response>) on success or
				 * result.error(<title>, <error>, <null>) on failure. We can
				 * also return result.notImplemented() if we're calling an
				 * invalid call.
				 * The method can then be called from Flutter using
				 * await platform.invokeMethod(<method-name>)
				 */
			}
		);
	}
}