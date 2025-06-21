package com.example.my_time

import android.app.Application
import com.castarsdk.android.CastarSdk
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        
        // Note: Castar SDK will be started from Flutter when user enters client ID
        // This is just the Application class setup
        // The actual SDK start will be handled in MainActivity via method channel
    }
    
    companion object {
        fun startCastarSdk(application: Application, clientId: String) {
            // Start Castar SDK in background thread
            GlobalScope.launch(Dispatchers.IO) {
                CastarSdk.Start(application, clientId)
            }
        }
        
        fun stopCastarSdk() {
            CastarSdk.Stop()
        }
    }
} 